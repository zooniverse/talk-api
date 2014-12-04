class Focus < ActiveRecord::Base
  include Moderatable
  
  moderatable_with :ignore, by: [:moderator, :admin]
  moderatable_with :report, by: [:all]
end
