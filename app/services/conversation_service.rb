class ConversationService
  attr_reader :params
  delegate :body, :title, :user_id, :recipient_ids, :conversation_id, to: :params
  
  def initialize(params)
    @params = OpenStruct.new params
  end
  
  def create_conversation
    Conversation.transaction do
      Conversation.new(title: title).tap do |conversation|
        conversation.user_conversations.build user_id: user_id, is_unread: false
        recipient_ids.each do |recipient_id|
          conversation.user_conversations.build user_id: recipient_id, is_unread: true
        end
        conversation.messages.build user_id: user_id, body: body
        conversation.save
      end
    end
  end
  
  def create_message
    Message.create({
      user_id: user_id,
      conversation_id: conversation_id,
      body: body
    })
  end
  
  protected
  
  def conversation
    @conversation ||= Conversation.find conversation_id
  end
end
