FactoryGirl.define do
  factory :conversation do
    title 'A conversation'
    
    factory :conversation_with_messages do
      transient do
        sender nil
        recipient nil
        message_count 2
      end
      
      after :create do |conversation, evaluator|
        sender = evaluator.sender || create(:user)
        recipient = evaluator.recipient || create(:user)
        conversation.user_conversations.create user: sender, is_unread: false
        conversation.user_conversations.create user: recipient, is_unread: true
        create_list :message, evaluator.message_count,
          sender: sender,
          recipient: recipient,
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
