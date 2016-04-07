module ActionRendering
  extend ActiveSupport::Concern

  def index
    authorize model_class
    scoped = policy_scope model_class
    params[:sort] ||= serializer_class.default_sort if serializer_class.default_sort
    render json: serializer_class.page(params, scoped, current_user: current_user)
  end

  def show
    authorize model_class.where(id: resource_ids)
    render json: serializer_class.resource(params, nil, current_user: current_user)
  end

  def create
    service.create
    render json: serializer_class.resource(service.resource, nil, current_user: current_user)
  end

  def update
    service.update
    render json: serializer_class.resource(service.resource, nil, current_user: current_user)
  end

  def destroy
    instance = model_class.find params[:id]
    authorize instance
    instance.destroy!
    render json: { }, status: :no_content
  end
end
