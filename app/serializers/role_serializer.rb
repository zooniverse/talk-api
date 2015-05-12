class RoleSerializer
  include TalkSerializer
  all_attributes
  can_include :user
end
