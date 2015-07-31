class OauthAccessToken < ActiveRecord::Base
  belongs_to :resource_owner, class_name: 'User'
end
