class MentionSerializer
  include TalkSerializer
  all_attributes
  
  can_include :comment
  can_filter_by :section, :mentionable_id, :mentionable_type
  can_sort_by :created_at
  self.default_sort = '-created_at'
end
