class Comment < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :discussion, counter_cache: true, touch: true, required: true
  belongs_to :focus, counter_cache: true
  belongs_to :board
  delegate :board, to: :discussion
  
  validates :body, presence: true
  
  before_create :denormalize_attributes
  after_create :update_counters
  after_destroy :update_counters
  
  protected
  
  def denormalize_attributes
    self.user_name = user.name
    self.focus_type ||= focus.type if focus
  end
  
  def update_counters
    discussion.count_users!
    board.count_users_and_comments! if board
  end
end
