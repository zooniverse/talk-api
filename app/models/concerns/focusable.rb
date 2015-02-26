module Focusable
  extend ActiveSupport::Concern
  
  included do
    include Moderatable
    has_many :mentions, as: :mentionable, dependent: :destroy
    has_many :comments, through: :mentions
    belongs_to :user
    
    validates :section, presence: true
    
    moderatable_with :ignore, by: [:moderator, :admin]
    moderatable_with :report, by: [:all]
  end
  
  def section
    "#{ project.id }-#{ project.name }"
  end
  
  def mentioned_by(comment)
    # TO-DO: notification for collection mentions?
  end
  
  def tags(limit: 10)
    Tag.where(taggable_id: id).popular(limit: limit).keys
  end
end