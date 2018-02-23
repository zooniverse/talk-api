class Message < ActiveRecord::Base
  include Notifiable

  belongs_to :user, required: true
  belongs_to :conversation, required: true, touch: true
  has_many :user_conversations, through: :conversation
  has_many :users, through: :user_conversations

  has_many :recipient_conversations,
    ->(message){
      where.not(user_id: message.user_id)
    },
    class_name: 'UserConversation',
    through: :conversation,
    source: :user_conversations

  has_many :recipients,
    class_name: 'User',
    through: :recipient_conversations,
    source: :user

  validates :body, presence: true

  before_create :ensure_user_conversations
  after_create :set_conversations_unread!

  concerning :Subscribing do
    included do
      after_create :subscribe_user
      after_commit :notify_subscribers_later, on: :create
    end

    def notify_subscribers_later
      MessageNotificationWorker.perform_async id
    end

    def notify_subscribers
      Subscription.messages.enabled.where(source: recipient_conversations, user: recipients).each do |subscription|
        Notification.create({
          source: self,
          user_id: subscription.user_id,
          message: "#{ user.display_name } has sent you a message",
          url: FrontEnd.link_to(self),
          section: 'zooniverse',
          subscription: subscription
        }) if subscription.try(:enabled?)
      end
    end

    def subscribe_user
      user_conversations.each do |user_conversation|
        user_conversation.user.subscribe_to user_conversation, :messages
      end
    end
  end

  def ensure_user_conversations
    conversation.participant_ids.each do |participant_id|
      conversation.user_conversations.where(user_id: participant_id).first_or_create
    end
  end

  def set_conversations_unread!
    recipient_conversations.update_all is_unread: true
  end
end
