class DataRequestSerializer
  include TalkSerializer
  all_attributes
  can_filter_by :kind
end
