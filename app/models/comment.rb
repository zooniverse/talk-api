class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :discussion, counter_cache: true, touch: true
  belongs_to :focus, counter_cache: true
  
  validates :body, presence: true
  validates :user, presence: true
  
  before_create :denormalize_attributes
  
  protected
  
  def denormalize_attributes
    self.user_name = user.name
    self.focus_type ||= focus.type if focus
  end
end
