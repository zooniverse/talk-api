module Searchable
  module Model
    extend ActiveSupport::Concern
    
    included do
      class_attribute :searchable_klass
      before_create :_denormalize
      after_create :set_content
      
      scope :with_content, ->(query_terms) {
        where 'content @@ to_tsquery(?)', query_terms
      }
    end
    
    module ClassMethods
      def searchable_model(klass)
        self.searchable_klass = klass
        belongs_to :searchable, class_name: klass.name
      end
    end
    
    def set_content
      self.class.connection.execute searchable.searchable_update
    end
    
    protected
    
    def _denormalize
      self.searchable_type = searchable_klass.name
      self.section = searchable.section
    end
  end
end
