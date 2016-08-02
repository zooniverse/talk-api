class UserSerializer
  include TalkSerializer
  include ModerationActions

  attributes :id, :created_at, :updated_at, :login, :display_name,
    :zooniverse_id, :credited_name, :admin, :banned

  def href
    nil
  end
end
