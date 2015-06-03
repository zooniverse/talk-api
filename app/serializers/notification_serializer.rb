class NotificationSerializer
  include TalkSerializer
  all_attributes
  can_sort_by :created_at
  can_filter_by :section, :delivered
  can_include :subscription
  self.default_sort = 'created_at'
end
