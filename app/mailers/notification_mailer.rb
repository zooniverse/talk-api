class NotificationMailer < ApplicationMailer
  include ActionView::Helpers::DateHelper
  add_template_helper MailerHelper
  
  after_action :set_delivered
  
  def notify(user, digest_frequency)
    @user = user
    frequency_enum = normalize_frequency digest_frequency
    categories = find_categories_for frequency_enum
    find_notifications_for categories
    organize
    
    mail to: @user.email, subject: subject(digest_frequency)
  end
  
  def find_categories_for(digest_frequency)
    @user.subscription_preferences.where(email_digest: digest_frequency).pluck :category
  end
  
  def find_notifications_for(categories)
    @notifications = @user.notifications
      .undelivered
      .joins(:subscription).where(subscriptions: { category: categories })
      .preload(:project)
      .includes(:source, subscription: :source)
      .order(created_at: :asc)
  end
  
  def organize
    @messages = select_category('messages').group_by{ |n| n.source.conversation }
    @mentions = select_category('mentions').group_by &:section
    @system = select_category('system').group_by &:section
    @participating = { }
    select_category('participating_discussions').each do |n|
      @participating[n.section] ||= { }
      @participating[n.section][n.subscription.source] ||= []
      @participating[n.section][n.subscription.source] << n
    end
  end
  
  def select_category(type)
    @notifications.select{ |notification| notification.subscription.category == type }
  end
  
  def set_delivered
    Notification.where(id: @notifications.map(&:id)).update_all delivered: true
  end
  
  def normalize_frequency(frequency)
    frequency.is_a?(Fixnum) ? frequency : SubscriptionPreference.email_digests[frequency]
  end
  
  def digest_label_for(frequency)
    {
      immediate: '',
      daily: 'Daily Digest of ',
      weekly: 'Weekly Digest of '
    }[frequency]
  end
  
  def subject(digest_frequency)
    "#{ digest_label_for digest_frequency }Zooniverse Talk Notifications"
  end
end
