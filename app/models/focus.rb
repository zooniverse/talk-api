class Focus < ActiveRecord::Base
  include Moderatable
  
  validates :section, presence: true
  
  moderatable_with :ignore, by: [:moderator, :admin]
  moderatable_with :report, by: [:all]
end
