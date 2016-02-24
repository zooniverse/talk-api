class CommentSerializer
  include TalkSerializer
  include EmbeddedAttributes
  include ModerationActions

  all_attributes except: [:user_ip]
  attributes :reply_user_id, :reply_user_login, :reply_user_display_name
  can_sort_by :created_at
  can_filter_by :user_id, :board_id, :focus_id, :focus_type
  embed_attributes_from :discussion, :board, :project
  self.default_sort = 'created_at'
  self.includes = [:user, :discussion, :board, :project]

  def custom_attributes
    super.merge user_display_name: model.user.display_name
  end

  def reply_user_id
    reply_user.id
  end

  def reply_user_login
    reply_user.login
  end

  def reply_user_display_name
    reply_user.display_name
  end

  protected

  def reply_user
    if model.reply_id
      _load_reply_user
    else
      OpenStruct.new
    end
  end

  def _load_reply_user
    return @reply_user if @reply_user
    login, display_name, id = Comment.where(id: model.reply_id).joins(:user).pluck('users.login', 'users.display_name', 'users.id').first
    @reply_user = OpenStruct.new(id: id, login: login, display_name: display_name)
  end
end
