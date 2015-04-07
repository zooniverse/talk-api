class ModerationSerializer
  include TalkSerializer
  all_attributes
  
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
