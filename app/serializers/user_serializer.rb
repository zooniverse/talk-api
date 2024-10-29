class UserSerializer
  include TalkSerializer
  include ModerationActions

  attributes :id, :created_at, :updated_at, :login, :display_name,
    :zooniverse_id, :credited_name, :admin, :banned, :valid_email, :confirmed_at

  def href
    nil
  end
end
