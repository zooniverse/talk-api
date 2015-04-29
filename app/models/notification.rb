class Notification < ActiveRecord::Base
  belongs_to :user, required: true
  scope :expired, ->{ where 'created_at < ?', 3.months.ago.utc }
end
