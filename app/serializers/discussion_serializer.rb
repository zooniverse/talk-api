class DiscussionSerializer
  include TalkSerializer
  include EmbeddedAttributes
  include ModerationActions
  
  all_attributes
  can_include :comments, :board, :user
  can_filter_by :title, :subject_default, :sticky
  can_sort_by :updated_at, :sticky, :sticky_position
  embed_attributes_from :project, :board
  self.default_sort = '-sticky,sticky_position,-updated_at'
  self.includes = [:user, :board, :project]
  
  def custom_attributes
    super.merge user_display_name: model.user.display_name
  end
end
