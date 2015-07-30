class TagSerializer
  include TalkSerializer
  include EmbeddedAttributes
  all_attributes
  embed_attributes_from :project
  self.eager_loads = [:project]
end
