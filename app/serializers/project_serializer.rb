class ProjectSerializer
  include TalkSerializer
  attributes :id, :display_name, :slug, :private,
    :launch_approved, :launched_row_order
  self.default_sort = '-launched_row_order'
end
