class ConversationService < ApplicationService
  def build
    set_user
    @resource = model_class.new(conversation_params).tap do |conversation|
      build_user_conversations_for conversation
      conversation.save
      conversation.messages << build_message
    end
  end

  def build_user_conversations_for(conversation)
    conversation.user_conversations.build user_id: current_user.id, is_unread: false

    raise Talk::BlockedUserError.new if blocked?
    raise Talk::UserBlockedError.new if blocking?
    raise Talk::UserUnconfirmedError.new if unconfirmed?
    recipient_ids.each do |recipient_id|
      conversation.user_conversations.build user_id: recipient_id, is_unread: true
    end
  end

  def build_message
    MessageService.new({
      params: message_params,
      action: :create,
      current_user: current_user,
      user_ip: user_ip
    }).build
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

  def blocked?
    BlockedUser.blocked_by(recipient_ids).blocking(current_user.id).exists?
  end

  def blocking?
    BlockedUser.blocked_by(current_user.id).blocking(recipient_ids).exists?
  end

  def unconfirmed?
    current_user.confirmed_at.nil?
  end
end
