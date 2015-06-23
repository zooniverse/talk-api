class RoleSerializer
  include TalkSerializer
  all_attributes
  can_include :user
  can_filter_by :section, :is_shown
end
