class Board < ActiveRecord::Base
  has_many :discussions, dependent: :restrict_with_error
  has_many :comments, through: :discussions
  has_many :users, through: :comments
  has_many :boards
  belongs_to :board
  
  validates :title, presence: true
  validates :description, presence: true
  validates :section, presence: true
  
  def count_users_and_comments!
    self.comments_count = comments.count
    self.users_count = users.select(:id).distinct.count
    save if changed?
  end
end
