class SuggestedTagSerializer
  include TalkSerializer
  all_attributes
  self.default_sort = 'name'
end
