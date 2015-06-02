module TalkSerializer
  extend ActiveSupport::Concern
  
  included do |klass|
    include RestPack::Serializer
    attr_reader :model
    attributes :href, :links
    
    class << self
      attr_accessor :default_sort
    end
    
    is_sectioned = model_class.columns_hash.has_key?('section') rescue false
    can_filter_by(:section) if is_sectioned
    
    def klass.resource(params = {}, scope = nil, context = {})
      return super if params.is_a?(model_class)
      params.select{ |key, val| key =~ /^sort_linked/ }.each_pair do |type, values|
        begin
          type = type.match(/^sort_linked_(.*)$/)[1]
          linked_serializer = "#{ type.singularize }_serializer".classify.safe_constantize
          sortable = linked_serializer.serializable_sorting_attributes
          ordering = values.split(',').collect do |value|
            direction = value =~ /^\-/ ? 'desc' : 'asc'
            value = value.gsub(/^\-/, '')
            next unless sortable.include?(value.to_sym)
            "#{ value } #{ direction }"
          end.compact
          
          context[:sort_links] ||= { }
          context[:sort_links][type] = ordering.join(', ') if ordering.any?
        rescue
        end
      end
      super
    end
  end
  
  module ClassMethods
    def all_attributes(except: [])
      attrs = model_class.attribute_names.sort rescue []
      except = Array.wrap(except).sort.collect &:to_s
      attributes *(attrs.sort - except)
    end
  end
  
  def links
    { }
  end
end
