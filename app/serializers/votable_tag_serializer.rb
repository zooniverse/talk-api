class VotableTagSerializer
  include TalkSerializer
  all_attributes
  can_filter_by :taggable_id, :taggable_type, :name, :section
  can_sort_by :name, :vote_count, :created_at, :updated_at
  self.default_sort = '-vote_count'
end
