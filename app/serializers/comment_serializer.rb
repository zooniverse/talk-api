class CommentSerializer
  include TalkSerializer
  include EmbeddedAttributes
  include ModerationActions
  
  all_attributes
  can_include :discussion
  can_sort_by :created_at
  can_filter_by :user_id, :focus_id, :focus_type
  embed_attributes_from :discussion, :board, :project
  self.default_sort = 'created_at'
  self.includes = [:user, :focus, :discussion, :board, :project]
  
  def custom_attributes
    super.merge focus: focus, user_display_name: model.user.display_name
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
