class Tag < ActiveRecord::Base
  validates :section, presence: true
end
