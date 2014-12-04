module Moderatable
  extend ActiveSupport::Concern
  
  included do
    has_one :moderation, as: :target
    class_attribute :moderatable
    self.moderatable = { }
  end
  
  module ClassMethods
    def moderatable_with(action, by: [])
      self.moderatable = self.moderatable.merge action => { }
      by.each{ |role| self.moderatable[action][role] = true }
    end
  end
end
