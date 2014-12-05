module TalkSerializer
  extend ActiveSupport::Concern
  
  included do
    include RestPack::Serializer
    attr_reader :model
    attributes :href, :links
    can_filter_by(:section) if model_class.columns_hash.has_key? 'section'
  end
  
  module ClassMethods
    def all_attributes
      attributes *model_class.attribute_names
    end
  end
  
  def links
    { }
  end
end
