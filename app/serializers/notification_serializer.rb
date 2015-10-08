class NotificationSerializer
  include TalkSerializer
  include EmbeddedAttributes
  
  all_attributes
  can_sort_by :created_at, :delivered
  can_filter_by :section, :delivered
  can_include :subscription
  embed_attributes_from :project
  self.default_sort = '-created_at'
  self.includes = [:project, :source]
  
  def custom_attributes
    super.merge source: source
  end
  
  def source
    source_serializer.as_json(model.source, current_user: current_user) if model.source
  rescue
    nil
  end
  
  def source_serializer
    RestPack::Serializer.class_map[model.source_type.underscore]
  end
end
