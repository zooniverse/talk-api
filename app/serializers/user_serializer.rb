class UserSerializer
  include TalkSerializer
  include ModerationActions
  
  all_attributes except: :email
end
