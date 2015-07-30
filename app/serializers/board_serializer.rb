class BoardSerializer
  include TalkSerializer
  include EmbeddedAttributes
  
  all_attributes
  can_include :discussions, :parent, :sub_boards
  can_filter_by :subject_default
  can_sort_by :created_at
  self.default_sort = 'created_at'
  self.eager_loads = [:project]
  
  def custom_attributes
    super.merge attributes_from :project
  end
end
