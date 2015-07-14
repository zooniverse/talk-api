class ModerationSerializer
  include TalkSerializer
  all_attributes
  can_filter_by :state
  can_sort_by :updated_at
  self.default_sort = 'state,-updated_at'
  
  def custom_attributes
    super.merge target: target
  end
  
  def target
    target_serializer.as_json(model.target) if model.target
  rescue
    nil
  end
  
  def target_serializer
    RestPack::Serializer.class_map[model.target_type.underscore]
  end
end
