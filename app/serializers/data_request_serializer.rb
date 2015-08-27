class DataRequestSerializer
  include TalkSerializer
  all_attributes
  can_filter_by :kind
  can_sort_by :created_at
  self.default_sort = '-created_at'
end
