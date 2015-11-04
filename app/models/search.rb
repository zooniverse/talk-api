class Search < ActiveRecord::Base
  include Searchable::Querying
  
  class_attribute :serializers
  self.serializers = Hash.new do |hash, klass|
    hash[klass] = "#{ klass }Serializer".constantize
  end
  
  belongs_to :searchable, polymorphic: true
  
  scope :of_type, ->(types){ where searchable_type: types }
  scope :in_section, ->(section){ where('sections @> array[?]::varchar[]', section) }
  scope :with_content, ->(terms) {
    query = _parse_query terms
    where('content @@ to_tsquery(?)', query)
      .order("ts_rank(content, #{ connection.quote query }) desc")
  }
  
  def self.serialize_search
    list = all.to_a
    ids_by_type = result_ids_by_type list
    results = load_results ids_by_type
    reorder_results list, results
  end
  
  def self.result_ids_by_type(list)
    { }.tap do |types|
      list.each do |search|
        types[search.searchable_type] ||= []
        types[search.searchable_type] << search.searchable_id
      end
    end
  end
  
  def self.load_results(ids_by_type)
    { }.tap do |results|
      ids_by_type.each_pair do |type, searchable_ids|
        results[type] = { }
        resource = serializers[type].resource id: searchable_ids.join(',')
        resource[type.tableize.to_sym].each do |hash|
          results[type][hash[:id].to_i] = hash.merge type: type
        end
      end
    end
  end
  
  def self.reorder_results(list, results)
    [].tap do |reordered|
      list.each do |search|
        result = results[search.searchable_type][search.searchable_id]
        reordered << result
      end
    end
  end
end
