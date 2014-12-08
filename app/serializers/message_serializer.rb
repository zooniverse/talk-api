class MessageSerializer
  include TalkSerializer
  all_attributes
  can_include :conversation, :user
end
