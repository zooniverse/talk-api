class Discussion < ActiveRecord::Base
  belongs_to :user
  belongs_to :board, counter_cache: true
  has_many :comments, dependent: :destroy
  
  validates :title, presence: true, length: 3..140
  validates :user, presence: true
  
  before_create :denormalize_attributes
  
  def count_users!
    self.users_count = comments.select(:user_id).distinct.count
    save if changed?
  end
  
  protected
  
  def denormalize_attributes
    self.user_name = user.name
  end
end
