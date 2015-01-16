class UserSerializer
  include TalkSerializer
  all_attributes except: :email
end
