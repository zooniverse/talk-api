module Moderatable
  extend ActiveSupport::Concern
  
  included do
    has_one :moderation, as: :target
  end
end
