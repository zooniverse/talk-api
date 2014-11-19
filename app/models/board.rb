class Board < ActiveRecord::Base
  has_many :discussions, dependent: :restrict_with_error
  
  validates :title, presence: true
  validates :description, presence: true
end
