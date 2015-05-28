module SubscriptionCategories
  extend ActiveSupport::Concern
  
  included do
    validates :category, inclusion: {
      in: %w(participating_discussions mentions messages)
    }
    
    enum category: {
      participating_discussions: 0,
      mentions: 1,
      messages: 2
    }
  end
end
