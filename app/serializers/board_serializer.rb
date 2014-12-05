class BoardSerializer
  include TalkSerializer
  all_attributes
  can_include :discussions
end
