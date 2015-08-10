class Notification < ActiveRecord::Base
  include Expirable
  include Sectioned
  
  belongs_to :source, polymorphic: true
  belongs_to :user, required: true
  belongs_to :subscription, required: true
  after_commit :publish, on: :create
  validates :url, presence: true
  validates :message, presence: true
  validates :section, presence: true
  
  expires_in 3.months
  
  protected
  
  def publish
    NotificationWorker.perform_async id
  end
end
