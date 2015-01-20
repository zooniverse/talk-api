class Focus < ActiveRecord::Base
  include Moderatable
  
  has_many :mentions, as: :mentionable, dependent: :destroy
  has_many :comments, through: :mentions
  belongs_to :user
  
  validates :section, presence: true
  
  moderatable_with :ignore, by: [:moderator, :admin]
  moderatable_with :report, by: [:all]
  
  def mentioned_by(comment)
    # TO-DO: notification for collection mentions?
  end
end
