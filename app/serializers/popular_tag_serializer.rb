class PopularTagSerializer
  include TalkSerializer
  all_attributes
  
  def self.key
    'popular'
  end
  
  def self.href_prefix
    '/tags'
  end
end
