module Focusable
  extend ActiveSupport::Concern
  
  included do
    include Moderatable
    has_many :mentions, as: :mentionable, dependent: :destroy
    has_many :comments, as: :focus
    belongs_to :user
    
    validates :section, presence: true
    
    moderatable_with :ignore, by: [:moderator, :admin]
    moderatable_with :report, by: [:all]
  end
  
  def section
    "#{ project.id }-#{ project.display_name }"
  end
  
  def mentioned_by(comment)
    # TO-DO: notification for collection mentions?
  end
end
