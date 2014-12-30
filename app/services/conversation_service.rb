class ConversationService < ApplicationService
  def initialize(*args)
    super
    set_user if action == :create
  end
  
  def build
    @resource = model_class.new(conversation_params).tap do |conversation|
      conversation.user_conversations.build user_id: current_user.id, is_unread: false
      
      recipient_ids.each do |recipient_id|
        conversation.user_conversations.build user_id: recipient_id, is_unread: true
      end
      
      conversation.messages << MessageService.new({
        params: message_params,
        action: :create,
        current_user: current_user
      }).build
    end
  end
  
  def conversation_params
    unrooted_params.except :body, :user_id, :recipient_ids
  end
  
  def recipient_ids
    unrooted_params.fetch :recipient_ids, []
  end
  
  def message_params
    ActionController::Parameters.new({
      messages: unrooted_params.slice(:body)
    })
  end
end
