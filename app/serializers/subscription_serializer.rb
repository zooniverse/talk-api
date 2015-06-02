class SubscriptionSerializer
  include TalkSerializer
  all_attributes
  can_include :notifications
  can_filter_by :source_id, :source_type
end
