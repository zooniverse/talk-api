class BlockedUser < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :blocked_user, class_name: 'User', required: true
  scope :blocked_by, ->(*user_ids){ where user_id: user_ids.flatten }
  scope :blocking, ->(*user_ids){ where blocked_user_id: user_ids.flatten }
end
