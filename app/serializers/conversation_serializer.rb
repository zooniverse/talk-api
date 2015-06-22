class ConversationSerializer
  include TalkSerializer
  include ModerationActions
  
  all_attributes
  attribute :is_unread
  can_include :messages
  
  def custom_attributes
    super.tap do |attrs|
      # All users able to view a conversation are able to report it
      attrs[:moderatable_actions] << :report
    end
  end
  
  def is_unread
    return unless model && current_user
    model.user_conversations.where(user: current_user).first.try :is_unread
  end
end
