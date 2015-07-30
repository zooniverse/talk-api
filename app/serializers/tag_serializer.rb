class TagSerializer
  include TalkSerializer
  include EmbeddedAttributes
  all_attributes
  can_filter_by :taggable_id, :taggable_type
  embed_attributes_from :project
  self.eager_loads = [:project]
end
