module ApiResource
  extend ActiveSupport::Concern
  
  included do
    class_attribute :panoptes_attributes
    self.panoptes_attributes = HashWithIndifferentAccess.new
  end
  
  module ClassMethods
    def panoptes_attribute(name, updateable: false)
      panoptes_attributes[name] = { updateable: updateable }
    end
    
    def updateable_panoptes_attributes
      panoptes_attributes.select{ |k, v| v[:updateable] }.keys
    end
    
    def from_panoptes(api_response)
      return unless api_response.success?
      hash = api_response.body[table_name].first
      find_or_create_from_panoptes(hash).tap do |record|
        record.update_from_panoptes hash
      end
    end
    
    def find_or_create_from_panoptes(hash)
      record = find_by_id hash['id']
      record ||= create hash.slice *panoptes_attributes.keys
    end
  end
  
  def update_from_panoptes(hash)
    attrs = hash.slice *self.class.updateable_panoptes_attributes
    attrs.each_pair{ |k, v| self[k] = v }
    save! if changed?
  end
end
