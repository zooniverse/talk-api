class UserConversation < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :user
  
  after_destroy :remove_conversation
  
  protected
  
  def remove_conversation
    conversation.reload.destroy rescue nil
  end
end
