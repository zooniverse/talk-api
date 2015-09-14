module SubscriptionCategories
  extend ActiveSupport::Concern
  
  included do
    validates :category, inclusion: {
      in: %w(participating_discussions mentions messages system followed_discussions moderation_reports group_mentions)
    }
    
    enum category: {
      participating_discussions: 0,
      mentions: 1,
      messages: 2,
      system: 3,
      followed_discussions: 4,
      moderation_reports: 5,
      group_mentions: 6
    }
  end
end
