class MessageSerializer
  include TalkSerializer
  all_attributes
  can_include :conversation, :user
  can_sort_by :conversation_id, :created_at
end
