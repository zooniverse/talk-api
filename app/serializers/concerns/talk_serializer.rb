module TalkSerializer
  extend ActiveSupport::Concern
  
  included do |klass|
    include RestPack::Serializer
    extend ClassMethodOverrides
    attr_reader :model
    attributes :href, :links
    
    class << self
      attr_accessor :eager_loads, :preloads, :includes
      attr_accessor :default_sort
    end
    
    self.eager_loads ||= []
    self.preloads ||= []
    self.includes ||= []
    is_sectioned = model_class.columns_hash.has_key?('section') rescue false
    can_filter_by(:section) if is_sectioned
    stringify_primary_key
    stringify_foreign_keys
  end
  
  module ClassMethods
    def all_attributes(except: [])
      attrs = model_class.attribute_names.sort rescue []
      except = Array.wrap(except).sort.collect &:to_s
      attributes *(attrs.sort - except)
    end
    
    def stringify_primary_key
      primary_key = model_class.primary_key
      define_method primary_key do
        model[primary_key].to_s
      end
    end
    
    def stringify_foreign_keys
      belong_tos = model_class.reflect_on_all_associations.select{ |a| a.macro == :belongs_to }
      belong_tos.each do |association|
        foreign_key = association.foreign_key
        define_method foreign_key do
          model[foreign_key].to_s
        end
      end
    end
    
    def current_sort_from(options)
      options.sorting.map do |attribute, direction|
        direction == :asc ? attribute : "-#{ attribute }"
      end.join ','
    end
  end
  
  module ClassMethodOverrides
    def serialize_meta(page, options)
      super.merge({
        current_sort: current_sort_from(options),
        default_sort: default_sort,
        sortable_attributes: serializable_sorting_attributes || []
      })
    end
    
    def resource(params = { }, scope = nil, context = { })
      super params, scope_preloading_for(scope), context
    end
    
    def page(params = { }, scope = nil, context = { })
      super params, scope_preloading_for(scope), context
    end
    
    def scope_preloading_for(scope)
      scope ||= model_class.all
      scope = scope.includes(*includes) if includes.any?
      scope = scope.preload(*preloads) if preloads.any?
      scope = scope.eager_load(*eager_loads) if eager_loads.any?
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
