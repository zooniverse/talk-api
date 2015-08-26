class BlockedUser < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :blocked_user, class_name: 'User', required: true
end
