class ProjectSerializer
  include TalkSerializer
  all_attributes
  self.default_sort = '-launched_row_order'
end
