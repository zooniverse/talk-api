class UserConversation < ActiveRecord::Base
  include Subscribable
  
  belongs_to :conversation
  belongs_to :user, required: true
  
  after_destroy :remove_conversation
  
  protected
  
  def remove_conversation
    conversation.reload.destroy rescue nil
  end
end
