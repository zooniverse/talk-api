module ActionRendering
  extend ActiveSupport::Concern
  
  def index
    authorize model_class
    scoped = policy_scope model_class
    render json: serializer_class.page(params, scoped)
  end
  
  def show
    authorize model_class.where(id: resource_ids)
    render json: serializer_class.resource(params)
  end
  
  def create
    raise ActionController::NotImplemented.new 'index, show'
  end
  
  def update
    raise ActionController::NotImplemented.new 'index, show'
  end
  
  def destroy
    instance = model_class.find params[:id]
    authorize instance
    instance.destroy!
    render json: { }, status: :no_content
  end
  
  def serializer_class
    @_serializer_class ||= "#{ model_class_name }Serializer".constantize
  end
  
  def model_class
    @_model_class ||= model_class_name.constantize
  end
  
  def model_class_name
    @_model_class_name ||= self.class.name.sub(/Controller$/, '').singularize
  end
  
  def resource_ids
    if params[:id].is_a? String
      params[:id].split(',').compact.collect &:to_i
    else
      params[:id]
    end
  end
end
