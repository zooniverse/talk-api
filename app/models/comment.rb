class Comment < ActiveRecord::Base
  include Moderatable
  include HashChanges
  include HstoreUpdate
  include Searchable
  include Sectioned
  include Notifiable
  include BooleanCoercion

  include Comment::Tagging
  include Comment::Mentioning
  include Comment::Subscribing
  include Comment::Publishing

  has_many :mentions, dependent: :destroy
  has_many :group_mentions, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :taggables, through: :tags

  belongs_to :reply, class_name: 'Comment'
  has_many :replies, class_name: 'Comment', foreign_key: :reply_id

  belongs_to :user, required: true
  belongs_to :discussion, counter_cache: true, touch: true, required: true
  belongs_to :focus, polymorphic: true
  belongs_to :board

  validates :body, presence: true
  validates :section, presence: true
  validates :focus_type, inclusion: {
    in: ['Subject', 'Collection'],
    if: ->{ focus_id.present? },
    message: 'must be "Subject" or "Collection"'
  }

  before_validation :set_section
  before_create :denormalize_attributes
  after_create :update_discussion
  before_update :update_board_id, if: ->{ discussion_id_changed? }
  after_update :update_moved_discussion
  after_destroy :update_discussion, :clear_replies

  moderatable_with :destroy, by: [:moderator, :admin]
  moderatable_with :ignore, by: [:moderator, :admin]
  moderatable_with :report, by: [:all]

  def upvote!(voter)
    hstore_concat 'upvotes', voter.login => Time.now.to_i
  end

  def remove_upvote!(voter)
    hstore_delete_key 'upvotes', voter.login
  end

  def soft_destroy
    update_attributes is_deleted: true, body: 'This comment has been deleted'
    mentions.destroy_all
    group_mentions.destroy_all
    tags.destroy_all
    close_moderation
    # prevent empty discussions
    discussion.destroy unless discussion.comments.where(is_deleted: false).any?
    self
  end

  def searchable?
    discussion.searchable? && !is_deleted?
  end

  def searchable_update
    <<-SQL
      update searchable_comments
      set content =
        setweight(to_tsvector(comments.body), 'B') ||
        setweight(to_tsvector(users.login), 'B') ||
        setweight(to_tsvector(users.display_name), 'B') ||
        setweight(to_tsvector(tag_list.names), 'A')
        #{ searchable_focus }
      from comments, users, (
        select coalesce(string_agg(name, ' '), '') as names
        from tags
        where comment_id = #{ id }
      ) as tag_list
      where searchable_comments.searchable_id = #{ id } and
      users.id = comments.user_id and
      comments.id = #{ id }
    SQL
  end

  def searchable_focus
    return '' unless focus
    <<-SQL
      || setweight(to_tsvector(focus_type), 'C')
      || setweight(to_tsvector(focus_id::text), 'A')
      || setweight(to_tsvector(substring(focus_type, 1, 1) || focus_id::text), 'A')
    SQL
  end

  protected

  def set_section
    self.section = discussion.section
  end

  def denormalize_attributes
    self.focus ||= discussion.focus if discussion.focus
    self.user_login = user.login
    self.board_id = discussion.board_id
  end

  def update_discussion
    discussion.last_comment_created_at = discussion.comments.order(created_at: :desc).first.try :created_at
    discussion.last_comment_created_at ||= discussion.created_at
    board.last_comment_created_at = discussion.last_comment_created_at
    board.save if board.changed?
    discussion.update_counters!
  end

  def update_board_id
    denormalize_attributes if board_id != discussion.board_id
  end

  def update_moved_discussion
    changes.fetch(:discussion_id, []).compact.each do |id|
      Discussion.find_by_id(id).try :update_counters!
    end
  end

  def clear_replies
    replies.update_all reply_id: nil
  end

  def url
    "#{FrontEnd.project_talk(project)}/#{board_id}/#{discussion_id}?comment=#{id}"
  end
end
