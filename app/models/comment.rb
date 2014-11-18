class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :discussion
  validates :body, presence: true
  validates :user, presence: true
  
  before_create :set_user_name
  
  protected
  
  def set_user_name
    self.user_name = user.name
  end
end
