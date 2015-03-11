class ConversationSerializer
  include TalkSerializer
  all_attributes
  can_include :messages
  can_sort_by :updated_at
  self.default_sort = 'updated_at'
end
