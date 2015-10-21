class MentionSerializer
  include TalkSerializer
  all_attributes
  
  can_include :comment
  can_filter_by :section
  can_sort_by :created_at
  self.default_sort = '-created_at'
end
