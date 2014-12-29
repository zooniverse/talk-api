module TalkResource
  extend ActiveSupport::Concern
  
  included do
    class_attribute :model_class, :serializer_class, :schema_class, :serializer_class, :service_class
    self.model_class = name.sub(/Controller$/, '').singularize.constantize rescue nil
    self.serializer_class = "#{ model_class.name }Serializer".constantize rescue nil
    self.schema_class = "#{ model_class.name }Schema".constantize rescue nil
    self.service_class = "#{ model_class.name }Service".constantize rescue ApplicationService
    attr_accessor :resource
  end
  
  def service
    @service ||= service_class.new({
      params: params,
      action: params[:action],
      current_user: current_user,
      model_class: model_class,
      schema_class: schema_class
    })
  end
  
  def resource_ids
    if params[:id].is_a? String
      params[:id].split(',').compact.collect &:to_i
    else
      params[:id]
    end
  end
end
