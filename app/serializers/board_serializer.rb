class BoardSerializer
  include TalkSerializer
  include EmbeddedAttributes
  
  all_attributes
  attribute :latest_discussion
  can_include :discussions, :parent, :sub_boards
  can_filter_by :subject_default
  can_sort_by :created_at
  embed_attributes_from :project
  self.default_sort = 'created_at'
  self.eager_loads = [:latest_discussion, :project, :parent]
  
  def latest_discussion
    DiscussionSerializer.as_json model.latest_discussion
  end
end
