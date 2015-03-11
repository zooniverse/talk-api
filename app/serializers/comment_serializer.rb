class CommentSerializer
  include TalkSerializer
  all_attributes
  can_sort_by :created_at
  self.default_sort = 'created_at'
  
  def custom_attributes
    {
      focus: focus
    }
  end
  
  def focus
    focus_serializer.as_json model.focus
  rescue
    nil
  end
  
  def focus_serializer
    RestPack::Serializer.class_map[model.focus_type.underscore]
  end
  
  def links
    {
      focus: model.focus_id.to_s,
      focus_type: model.focus_type
    } if model.focus_id
  end
end
