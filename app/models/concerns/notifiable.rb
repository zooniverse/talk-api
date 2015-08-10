module Notifiable
  extend ActiveSupport::Concern
  
  included do
    has_many :notifications, as: :source, dependent: :destroy
  end
end
