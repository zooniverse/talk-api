class SearchableCollection < ActiveRecord::Base
  class_attribute :searchable_klass
  self.searchable_klass = Collection
  belongs_to :searchable, class_name: 'Collection'

  scope :with_content, ->(query_terms) {
    where 'content @@ to_tsquery(?)', query_terms
  }
end
