class DiscussionSerializer
  include TalkSerializer
  all_attributes
  can_include :comments, :board, :user
end
