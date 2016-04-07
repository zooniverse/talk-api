class Board < ActiveRecord::Base
  include Searchable
  include Sectioned
  include Subscribable
  include BooleanCoercion

  has_many :discussions, dependent: :destroy
  has_one :latest_discussion, ->{
    includes(DiscussionSerializer.includes)
      .select('distinct on(discussions.board_id) discussions.*')
      .reorder board_id: :asc, last_comment_created_at: :desc
  }, class_name: 'Discussion'
  has_many :comments
  has_many :mentions
  has_many :sub_boards, class_name: 'Board', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Board'

  validates :title, presence: true
  validates :description, presence: true
  validates :section, presence: true

  after_update :cascade_searchable_later, if: :permissions_changed?

  def searchable?
    permissions['read'] == 'all'
  end

  def searchable_update
    <<-SQL
      update searchable_boards
      set content =
        setweight(to_tsvector(boards.title), 'A') ||
        setweight(to_tsvector(boards.description), 'A')
      from boards
      where searchable_boards.searchable_id = #{ id } and
      boards.id = #{ id }
    SQL
  end

  def count_users_and_comments!
    self.comments_count = Comment.where(board_id: id).count
    self.users_count = Comment.where(board_id: id).select(:user_id).distinct.count
    save if changed?
  end

  def cascade_searchable_later
    action = if permissions_was['read'] == 'all' && permissions['read'] != 'all'
      :destroy_searchable # was public, but isn't now
    elsif permissions_was['read'] != 'all' && permissions['read'] == 'all'
      :update_searchable # wasn't public, but is now
    end

    BoardVisibilityWorker.perform_in(1.second, id, action) if action
  end

  def each_discussion_and_comment
    discussions.find_each do |discussion|
      yield discussion
      discussion.comments.find_each do |comment|
        yield comment
      end
    end
  end
end
