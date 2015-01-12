class Comment < ActiveRecord::Base
  include Moderatable
  
  belongs_to :user, required: true
  belongs_to :discussion, counter_cache: true, touch: true, required: true
  belongs_to :focus, counter_cache: true
  belongs_to :board
  delegate :board, to: :discussion
  
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
