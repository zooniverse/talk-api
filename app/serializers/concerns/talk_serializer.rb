module TalkSerializer
  extend ActiveSupport::Concern
  
  included do
    include RestPack::Serializer
    attr_reader :model
    attributes :href, :links
    
    is_sectioned = model_class.columns_hash.has_key?('section') rescue false
    can_filter_by(:section) if is_sectioned
  end
  
  module ClassMethods
    def all_attributes
      attrs = model_class.attribute_names rescue []
      attributes *attrs
    end
  end
  
  def links
    { }
  end
end
