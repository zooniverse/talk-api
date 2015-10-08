class Moderation < ActiveRecord::Base
  include Notifiable
  include Sectioned
  
  belongs_to :target, polymorphic: true
  validates :target, presence: true, on: :create
  validates :section, presence: true
  
  before_update :reopen, if: :reports_changed?
  before_update :apply_action, if: :actions_changed?
  
  enum state: {
    opened: 0,
    ignored: 1,
    closed: 2,
    watched: 3
  }
  
  concerning :Subscribing do
    included do
      after_create :subscribe_users
      after_commit :notify_subscribers_later, on: :create
    end
    
    def notify_subscribers_later
      ModerationNotificationWorker.perform_async id
    end
    
    def notify_subscribers
      Subscription.moderation_reports.enabled.where(source: self, user: moderators).each do |subscription|
        Notification.create({
          source: self,
          user_id: subscription.user_id,
          message: "A #{ target_type.downcase } has been reported",
          url: FrontEnd.link_to(self),
          section: section,
          subscription: subscription
        }) if subscription.try(:enabled?)
      end
    end
    
    def subscribe_users
      moderators.find_each do |user|
        user.subscribe_to self, :moderation_reports
      end
    end
    
    def moderators
      @moderators ||= User.joins(:roles).where(roles: { name: %w(moderator admin), section: section }).all
    end
  end
  
  protected
  
  def apply_action
    self.actioned_at = Time.now.utc
    case actions.last.with_indifferent_access[:action]
    when 'destroy'
      destroy_target
    when 'ignore'
      ignore_target
    when 'watch'
      watch_target
    end
  end
  
  def reopen
    self.state = 'opened'
  end
  
  def destroy_target
    update_columns state: Moderation.states[:closed]
    self.destroyed_target = target.as_json
    target_type == 'Comment' ? target.soft_destroy : target.destroy!
    self.target = nil
  end
  
  def ignore_target
    self.state = 'ignored'
  end
  
  def watch_target
    self.state = 'watched'
  end
end
