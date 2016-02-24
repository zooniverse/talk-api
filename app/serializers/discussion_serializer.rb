class DiscussionSerializer
  include TalkSerializer
  include EmbeddedAttributes
  include ModerationActions

  all_attributes
  attribute :latest_comment
  can_filter_by :title, :subject_default, :sticky
  can_sort_by :last_comment_created_at, :sticky, :sticky_position
  embed_attributes_from :project, :board
  self.default_sort = '-sticky,sticky_position,-last_comment_created_at'
  self.preloads = [:latest_comment, :user]
  self.eager_loads = [:board, :project]

  def custom_attributes
    super.merge user_display_name: model.user.display_name
  end

  def latest_comment
    CommentSerializer.as_json model.latest_comment
  end

  def links
    return { } unless comment_sorting = params[:sort_linked_comments]
    direction = comment_sorting =~ /^\-/ ? :desc : :asc
    comment_ids = model.comments.order(created_at: direction).pluck(:id).map &:to_s
    { comments: comment_ids }
  end
end
