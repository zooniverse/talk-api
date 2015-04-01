class Comment < ActiveRecord::Base
  include Moderatable
  include HashChanges
  include HstoreUpdate
  include Searchable
  
  has_many :mentions, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :taggables, through: :tags
  
  belongs_to :user, required: true
  belongs_to :discussion, counter_cache: true, touch: true, required: true
  belongs_to :focus, polymorphic: true
  has_one :board, through: :discussion
  
  validates :body, presence: true
  validates :section, presence: true
  
  before_validation :set_section
  before_create :denormalize_attributes
  after_create :update_counters
  after_update :update_discussion_counters
  after_destroy :update_counters
  
  moderatable_with :destroy, by: [:moderator, :admin]
  moderatable_with :ignore, by: [:moderator, :admin]
  moderatable_with :report, by: [:all]
  
  def upvote!(voter)
    hstore_concat 'upvotes', voter.display_name => Time.now.to_i
  end
  
  def remove_upvote!(voter)
    hstore_delete_key 'upvotes', voter.display_name
  end
  
  def soft_destroy
    update_attributes is_deleted: true, body: 'This comment has been deleted'
    mentions.destroy_all
    tags.destroy_all
    # prevent empty discussions
    discussion.destroy unless discussion.comments.where(is_deleted: false).any?
    self
  end
  
  def searchable?
    return @searchable if @searchable
    @searchable = discussion.searchable?
  end
  
  def searchable_update
    <<-SQL
      update searchable_comments
      set content =
        setweight(to_tsvector(comments.body), 'B') ||
        setweight(to_tsvector(users.display_name), 'B') ||
        setweight(to_tsvector(users.display_name), 'B') ||
        setweight(to_tsvector(tag_list.names), 'A')
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
  
  concerning :Tagging do
    MATCH_TAGS = /
      (?:^|[^\w])         # match the beginning of the word
      (\#([-\w\d]{3,40})) # match tags
    /imx
    
    included do
      before_save :parse_tags
      before_update :parse_tags, :update_tags
    end
    
    def parse_tags
      self.tagging = { }
      body.scan(MATCH_TAGS).each do |tag, name|
        tagged tag, name.downcase
      end
    end
    
    def update_tags
      removed_from(:tagging).each_pair do |tag, name|
        Tag.where(comment_id: id, name: name).destroy_all
      end
    end
    
    protected
    
    def tagged(tag, name)
      self.tagging[tag] = name.downcase
      tags.build(name: name) if added_to(:tagging)[tag]
    end
  end
  
  concerning :Mentioning do
    MATCH_MENTIONS = /
      (?:^|\s)            # match the beginning of the word
      ( \^([SC])(\d+) ) | # match mentioned focuses
      ( @([-\w\d]{3,}) )  # match mentioned users
    /imx
    
    included do
      before_save :parse_mentions
      before_update :parse_mentions, :update_mentions
    end
    
    def parse_mentions
      self.mentioning = { }
      body.scan(MATCH_MENTIONS).each do |focus_mention, focus_type, focus_id, user_mention, display_name|
        if focus_mention
          focus_klass = { 'S' => Subject, 'C' => Collection }[focus_type]
          mentioned focus_mention, focus_klass.find_by_id(focus_id)
        else
          mentioned user_mention, User.find_by_display_name(display_name)
        end
      end
    end
    
    def update_mentions
      removed_from(:mentioning).each_pair do |mention, hash|
        Mention.where(comment_id: id, mentionable_id: hash['id']).destroy_all
      end
    end
    
    protected
    
    def mentioned(mention, mentionable)
      return unless mentionable
      self.mentioning[mention] = { 'id' => mentionable.id, 'type' => mentionable.class.name }
      mentions.build(user: user, mentionable: mentionable) if added_to(:mentioning)[mention]
    end
  end
  
  protected
  
  def set_section
    self.section = discussion.section
  end
  
  def denormalize_attributes
    self.user_display_name = user.display_name
  end
  
  def update_counters
    discussion.update_counters!
  end
  
  def update_discussion_counters
    changes.fetch(:discussion_id, []).compact.each do |id|
      Discussion.find_by_id(id).try :update_counters!
    end
  end
end
