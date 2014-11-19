class Discussion < ActiveRecord::Base
  belongs_to :user
  belongs_to :board
  has_many :comments, dependent: :destroy
  
  validates :title, presence: true, length: 3..140
  validates :user, presence: true
  
  before_create :denormalize_attributes
  
  protected
  
  def denormalize_attributes
    self.user_name = user.name
  end
end
