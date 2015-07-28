module TalkSerializer
  extend ActiveSupport::Concern
  
  included do |klass|
    include RestPack::Serializer
    extend ClassMethodOverrides
    attr_reader :model
    attributes :href, :links
    
    class << self
      attr_accessor :eager_loads
      attr_accessor :default_sort
    end
    
    self.eager_loads ||= []
    is_sectioned = model_class.columns_hash.has_key?('section') rescue false
    can_filter_by(:section) if is_sectioned
    stringify_primary_and_foreign_keys
  end
  
  module ClassMethods
    def all_attributes(except: [])
      attrs = model_class.attribute_names.sort rescue []
      except = Array.wrap(except).sort.collect &:to_s
      attributes *(attrs.sort - except)
    end
    
    def stringify_primary_and_foreign_keys
      primary_key = model_class.primary_key
      define_method primary_key do
        model[primary_key].to_s
      end
      
      belong_tos = model_class.reflect_on_all_associations.select{ |a| a.macro == :belongs_to }
      belong_tos.each do |association|
        foreign_key = association.foreign_key
        define_method foreign_key do
          model[foreign_key].to_s
        end
      end
    end
  end
  
  module ClassMethodOverrides
    def resource(params = { }, scope = nil, context = { })
      super params, scope_eager_loads_for(scope), context
    end
    
    def page(params = { }, scope = nil, context = { })
      super params, scope_eager_loads_for(scope), context
    end
    
    def scope_eager_loads_for(scope)
      scope ||= model_class.all
      scope = scope.includes(*eager_loads) if eager_loads.any?
      scope
    end
  end
  
  def links
    { }
  end
  
  def current_user
    @context[:current_user]
  end
end
