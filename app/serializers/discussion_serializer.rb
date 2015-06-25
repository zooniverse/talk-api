class DiscussionSerializer
  include TalkSerializer
  include ModerationActions
  
  all_attributes
  can_include :comments, :board, :user
  can_filter_by :title, :subject_default, :sticky
  can_sort_by :updated_at, :sticky, :sticky_position
  self.default_sort = '-sticky,sticky_position,-updated_at'
  
  def custom_attributes
    super.merge user_display_name: model.user.display_name
  end
end
