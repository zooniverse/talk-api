class Comment < ActiveRecord::Base
  include Moderatable
  include HashChanges
  
  has_many :mentions, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :taggables, through: :tags
  
  belongs_to :user, required: true
  belongs_to :discussion, counter_cache: true, touch: true, required: true
  belongs_to :focus, counter_cache: true
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
      ( \^[SC](\d+) ) |   # match mentioned focuses
      ( @([-\w\d]{3,}) )  # match mentioned users
    /imx
    
    included do
      before_save :parse_mentions
      before_update :parse_mentions, :update_mentions
    end
    
    def parse_mentions
      self.mentioning = { }
      body.scan(MATCH_MENTIONS).each do |focus_mention, focus_id, user_mention, login|
        if focus_mention
          mentioned focus_mention, Focus.find_by_id(focus_id)
        else
          mentioned user_mention, User.find_by_login(login)
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
    self.user_login = user.login
    self.focus_type ||= focus.type if focus
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
