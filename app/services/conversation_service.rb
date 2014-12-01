class ConversationService
  attr_reader :params
  delegate :body, :title, :sender_id, :recipient_id, :conversation_id, to: :params
  
  def initialize(params)
    @params = OpenStruct.new params
  end
  
  def create_conversation
    Conversation.transaction do
      Conversation.new(title: title).tap do |conversation|
        conversation.user_conversations.build user_id: sender_id, is_unread: false
        conversation.user_conversations.build user_id: recipient_id
        conversation.messages.build sender_id: sender_id, recipient_id: recipient_id, body: body
        conversation.save
      end
    end
  end
  
  def create_message
    Message.create({
      sender_id: sender_id,
      recipient_id: recipient_id,
      conversation_id: conversation_id,
      body: body
    })
  end
  
  protected
  
  def conversation
    @conversation ||= Conversation.find conversation_id
  end
end
