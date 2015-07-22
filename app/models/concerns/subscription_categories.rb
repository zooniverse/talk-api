module SubscriptionCategories
  extend ActiveSupport::Concern
  
  included do
    validates :category, inclusion: {
      in: %w(participating_discussions mentions messages system)
    }
    
    enum category: {
      participating_discussions: 0,
      mentions: 1,
      messages: 2,
      system: 3
    }
  end
end
