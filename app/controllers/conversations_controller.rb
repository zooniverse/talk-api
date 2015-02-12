class ConversationsController < ApplicationController
  include TalkResource
  
  def index
    authorize model_class
    scoped = policy_scope model_class
    scoped = scoped.unread if params.delete(:unread)
    render json: serializer_class.page(params, scoped)
  end
  
  def show
    super
    Conversation.mark_as_read_by resource_ids, current_user.id
  end
end
