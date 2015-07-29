class CommentSerializer
  include TalkSerializer
  include ModerationActions
  
  all_attributes
  can_include :discussion
  can_sort_by :created_at
  can_filter_by :user_id, :focus_id, :focus_type
  self.default_sort = 'created_at'
  self.eager_loads = [:user, :focus, :discussion, :board, :project]
  
  def custom_attributes
    super
      .merge(attributes_from(:discussion))
      .merge(attributes_from(:board))
      .merge(attributes_from(:project))
      .merge focus: focus, user_display_name: model.user.display_name
  end
  
  def discussion_attributes
    %w(comments_count subject_default title updated_at users_count)
  end
  
  def board_attributes
    %w(comments_count description discussions_count id parent_id subject_default title users_count)
  end
  
  def project_attributes
    %w(slug)
  end
  
  def attributes_from(relation)
    { }.tap do |attrs|
      record_attributes = model.send(relation).attributes rescue { }
      send("#{ relation }_attributes").each do |attr|
        value = record_attributes[attr]
        value = value.to_s if attr =~ /(_id)|(^id$)$/
        attrs[:"#{ relation }_#{ attr }"] = value
      end
    end
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
