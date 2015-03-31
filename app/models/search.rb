class Search < ActiveRecord::Base
  include Searchable::Querying
  
  belongs_to :searchable, polymorphic: true
  
  scope :of_type, ->(types){ where searchable_type: types }
  scope :in_section, ->(section){ where section: section }
  scope :with_content, ->(terms) {
    query = _parse_query terms
    where('content @@ to_tsquery(?)', query)
      .order("ts_rank(content, #{ connection.quote query }) desc")
  }
  
  paginates_per 10
  max_paginates_per 100
end
