class PopularSectionFocusTagSerializer
  include TalkSerializer
  all_attributes
  can_filter_by :name, :taggable_type

  def self.key
    'popular'
  end

  def self.href_prefix
    '/tags'
  end
end
