class BoardSerializer
  include TalkSerializer
  all_attributes except: :permissions
  can_include :discussions, :parent, :sub_boards
  can_sort_by :created_at
  self.default_sort = 'created_at'
end
