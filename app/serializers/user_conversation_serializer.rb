class UserConversationSerializer
  include TalkSerializer
  all_attributes
  can_include :user, :conversation
end
