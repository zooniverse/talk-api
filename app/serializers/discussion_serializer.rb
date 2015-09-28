class DiscussionSerializer
  include TalkSerializer
  include EmbeddedAttributes
  include ModerationActions
  
  all_attributes
  attribute :latest_comment
  can_include :comments, :board, :user
  can_filter_by :title, :subject_default, :sticky
  can_sort_by :last_comment_created_at, :sticky, :sticky_position
  embed_attributes_from :project, :board
  self.default_sort = '-sticky,sticky_position,-last_comment_created_at'
  self.preloads = [:latest_comment]
  self.includes = [:user, :board, :project]
  
  def custom_attributes
    super.merge user_display_name: model.user.display_name
  end
  
  def latest_comment
    CommentSerializer.as_json model.latest_comment
  end
end
