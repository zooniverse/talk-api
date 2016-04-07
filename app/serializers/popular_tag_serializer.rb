class PopularTagSerializer
  include TalkSerializer
  all_attributes
  can_filter_by :name

  def self.key
    'popular'
  end

  def self.href_prefix
    '/tags'
  end
end
