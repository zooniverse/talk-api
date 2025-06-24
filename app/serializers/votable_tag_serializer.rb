class VotableTagSerializer
  include TalkSerializer
  include EmbeddedAttributes
  all_attributes
  can_filter_by :taggable_id, :taggable_type
  can_sort_by :name, :vote_count
  embed_attributes_from :project
  self.includes = [:project]
end
