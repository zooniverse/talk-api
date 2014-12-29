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
    service.create
    render json: serializer_class.resource(service.resource)
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
end
