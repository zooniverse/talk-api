class CommentSerializer
  include TalkSerializer
  include EmbeddedAttributes
  include ModerationActions
  
  all_attributes except: [:user_ip]
  can_include :discussion
  can_sort_by :created_at
  can_filter_by :user_id, :focus_id, :focus_type
  embed_attributes_from :discussion, :board, :project
  self.default_sort = 'created_at'
  self.includes = [:user, :discussion, :board, :project]
  
  def custom_attributes
    super.merge user_display_name: model.user.display_name
  end
end
