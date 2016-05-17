class BoardSerializer
  include TalkSerializer
  include EmbeddedAttributes

  all_attributes
  attribute :latest_discussion
  can_filter_by :subject_default
  can_sort_by :id, :position, :last_comment_created_at
  embed_attributes_from :project
  self.default_sort = 'position,-last_comment_created_at'
  self.preloads = [:latest_discussion]
  self.eager_loads = [:project, :parent]

  def latest_discussion
    DiscussionSerializer.as_json model.latest_discussion
  end
end
