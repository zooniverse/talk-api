FactoryGirl.define do
  factory :message do
    user
    conversation
    body{ "Message from #{ user.name }" }
    
    before :create do |message, evaluator|
      UserConversation.find_or_create_by(conversation_id: message.conversation_id, user_id: message.user_id) do |user_conversation|
        user_conversation.is_unread = false
      end
    end
  end
end
