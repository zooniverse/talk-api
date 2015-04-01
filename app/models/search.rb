class Search < ActiveRecord::Base
  include Searchable::Querying
  
  class_attribute :serializers
  self.serializers = Hash.new do |hash, klass|
    hash[klass] = "#{ klass }Serializer".constantize
  end
  
  belongs_to :searchable, polymorphic: true
  
  scope :of_type, ->(types){ where searchable_type: types }
  scope :in_section, ->(section){ where section: section }
  scope :with_content, ->(terms) {
    query = _parse_query terms
    where('content @@ to_tsquery(?)', query)
      .order("ts_rank(content, #{ connection.quote query }) desc")
  }
  
  def self.serialize_search
    preload(:searchable).collect &:serialize
  end
  
  def serialize
    serializers[searchable_type].as_json searchable
  end
end
