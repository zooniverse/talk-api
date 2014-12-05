class ConversationSerializer
  include TalkSerializer
  all_attributes
  can_include :messages
end
