class FocusSerializer
  include TalkSerializer
  all_attributes
  can_include :mentions, :comments
end
