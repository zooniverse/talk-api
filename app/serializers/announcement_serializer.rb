class AnnouncementSerializer
  include TalkSerializer
  include EmbeddedAttributes
  
  all_attributes
  can_sort_by :created_at
  can_filter_by :section
  embed_attributes_from :project
  self.default_sort = 'created_at'
  self.includes = [:project]
end
