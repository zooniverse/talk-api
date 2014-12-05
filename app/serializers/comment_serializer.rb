class CommentSerializer
  include TalkSerializer
  all_attributes
  can_include :focus
  
  def links
    {
      focus_type: model.focus_type
    } if model.focus_id
  end
end
