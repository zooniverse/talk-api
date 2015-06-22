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
  
  def current_user
    @context[:current_user]
  end
end
