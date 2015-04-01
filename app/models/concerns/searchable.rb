module Searchable
  extend ActiveSupport::Concern
  
  included do
    include Searchable::Querying
    class_attribute :searchable_klass
    klass_name = "Searchable#{ name }"
    self.searchable_klass = if Object.const_defined?(klass_name)
      Object.const_get klass_name
    else
      Object.const_set klass_name, _searchable_model
    end
    
    after_create :create_searchable, if: :searchable?
    after_update :update_searchable, if: :searchable?
    after_update :destroy_searchable, unless: :searchable?
    has_one :searchable, class_name: searchable_klass.name, foreign_key: :searchable_id
  end
  
  module ClassMethods
    def _searchable_model
      klass = self
      @_searchable_model ||= Class.new(ActiveRecord::Base) do
        include Searchable::Model
        searchable_model klass
      end
    end
  end
  
  def searchable?
    true # by default
  end
  
  def create_searchable
    searchable_klass.create searchable: self
  end
  
  def update_searchable
    searchable ? searchable.set_content : create_searchable
  end
  
  def destroy_searchable
    searchable.try :destroy
  end
end
