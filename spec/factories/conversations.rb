FactoryBot.define do
  factory :conversation do
    title { 'A conversation' }

    factory :conversation_with_messages do
      transient do
        user nil
        recipients nil
        message_count { 2 }
      end

      after :create do |conversation, evaluator|
        user = evaluator.user || create(:user)
        recipients = evaluator.recipients || create_list(:user, 1)
        conversation.user_conversations.create user: user, is_unread: false

        recipients.each do |recipient|
          conversation.user_conversations.create user: recipient, is_unread: true
        end

        create_list :message, evaluator.message_count,
          user: user,
          conversation: conversation
      end

      factory :read_conversation do
        after :create do |conversation, evaluator|
          conversation.user_conversations.each do |user_conversation|
            user_conversation.is_unread = false
            user_conversation.save
          end
        end
      end
    end
  end
end
