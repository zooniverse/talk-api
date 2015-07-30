class TagSerializer
  include TalkSerializer
  include EmbeddedAttributes
  all_attributes
  self.eager_loads = [:project]
  
  def custom_attributes
    super.merge attributes_from :project
  end
end
