class UserSerializer
  include TalkSerializer
  include ModerationActions
  
  attributes :id, :created_at, :updated_at, :display_name,
    :zooniverse_id, :credited_name, :admin, :banned
end
