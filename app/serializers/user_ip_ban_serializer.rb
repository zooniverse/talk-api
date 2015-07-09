class UserIpBanSerializer
  include TalkSerializer
  all_attributes
  can_sort_by :ip
end
