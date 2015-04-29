class Notification < ActiveRecord::Base
  belongs_to :user
  scope :expired, ->{ where 'created_at < ?', 3.months.ago.utc }
end
