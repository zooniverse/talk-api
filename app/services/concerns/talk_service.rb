module TalkService
  extend ActiveSupport::Concern
  
  class ParameterError < StandardError; end
  
  included do
    class_attribute :model_class
    class_attribute :schema_class
    
    attr_accessor :params, :action, :current_user, :model_class, :schema_class
    attr_accessor :resource
  end
  
  module ClassMethods
    def inherited(base)
      base.model_class = base.name.sub(/Service$/, '').singularize.constantize
      base.schema_class = "#{ base.model_class.name }Schema".constantize
    end
  end
  
  def initialize(params: params, action: actions, current_user: current_user, model_class: nil, schema_class: nil)
    @params = params
    @action = action.to_sym
    @current_user = current_user
    @model_class = model_class || self.class.model_class
    @schema_class = schema_class || self.class.schema_class
  end
  
  def build
    @resource = model_class.new unrooted_params
  end
  
  def create
    build unless resource
    authorize unless authorized?
    validate unless validated?
    resource.save!
  end
  
  def authorize
    build unless resource
    @authorized = policy.send "#{ action }?"
    unauthorized! unless authorized?
  end
  
  def validate
    schema = schema_class.new(policy: policy).send action
    @validated = schema.validate! rooted_params
  end
  
  def policy
    Pundit.policy! current_user, resource
  end
  
  def validated?
    !!@validated
  end
  
  def authorized?
    !!@authorized
  end
  
  def set_user
    unauthorized! unless current_user
    begin
      if block_given?
        yield
      else
        unrooted_params[:user_id] = current_user.id if current_user
      end
    rescue
      raise TalkService::ParameterError.new
    end
  end
  
  def permitted_params
    params.permitted? ? params : params.permit!
  end
  
  def rooted_params
    permitted_params.slice model_class.table_name
  end
  
  def unrooted_params
    permitted_params[model_class.table_name] || ActionController::Parameters.new
  end
  
  protected
  
  def unauthorized!
    raise Pundit::NotAuthorizedError.new "not allowed to #{ action } this #{ resource.class }"
  end
end
