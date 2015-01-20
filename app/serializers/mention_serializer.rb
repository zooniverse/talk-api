class MentionSerializer
  include TalkSerializer
  all_attributes
  can_include :comment, :user
end
