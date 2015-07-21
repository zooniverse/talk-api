class Project < ActiveRecord::Base
  include Subscribable
  
  def self.from_section(section)
    find section.match(/project-(\d+)/)[1]
  rescue
    nil
  end
  
  def create_system_notification(user, notification)
    subscription = user.subscribe_to self, :system
    
    Notification.create(notification.merge({
      user_id: user.id,
      section: "project-#{ id }",
      subscription: subscription
    })) if subscription.try(:enabled?)
  end
end
