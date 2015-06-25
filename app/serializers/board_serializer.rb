class BoardSerializer
  include TalkSerializer
  all_attributes
  can_include :discussions, :parent, :sub_boards
  can_filter_by :subject_default
  can_sort_by :created_at
  self.default_sort = 'created_at'
end
