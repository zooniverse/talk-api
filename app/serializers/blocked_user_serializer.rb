class BlockedUserSerializer
  include TalkSerializer
  
  all_attributes
  can_sort_by :created_at
  self.default_sort = 'created_at'
end
