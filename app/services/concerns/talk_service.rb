module TalkService
  extend ActiveSupport::Concern
  
  class ParameterError < StandardError; end
  
  included do
    class_attribute :model_class
    class_attribute :schema_class
    
    attr_accessor :params, :action, :current_user, :model_class, :schema_class, :user_ip
    attr_accessor :resource
  end
  
  def initialize(params:, action:, current_user:, model_class: nil, schema_class: nil, user_ip: nil)
    @params = params
    @action = action.to_sym
    @current_user = current_user
    @user_ip = user_ip
    @model_class = model_class || self.class.model_class
    @schema_class = schema_class || self.class.schema_class
  end
  
  def build
    @resource = model_class.new unrooted_params
  rescue ArgumentError => e
    reraise_enum_errors e
  rescue NameError => e
    reraise_constantize_errors e
  end
  
  def find_resource
    @resource = model_class.find params[:id]
  end
  
  def update_resource
    resource.assign_attributes unrooted_params
  rescue ArgumentError => e
    reraise_enum_errors e
  rescue NameError => e
    reraise_constantize_errors e
  end
  
  def create
    build unless resource
    authorize unless authorized?
    validate unless validated?
    resource.save!
  rescue NameError => e
    reraise_constantize_errors e
  end
  
  def update
    find_resource unless resource
    authorize unless authorized?
    update_resource
    validate unless validated?
    resource.save!
  rescue NameError => e
    reraise_constantize_errors e
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
    build unless resource
    Pundit.policy! current_user, resource
  end
  
  def validated?
    !!@validated
  end
  
  def authorized?
    !!@authorized
  end
  
  def set_user(&block)
    unauthorized! unless current_user
    begin
      if block_given?
        instance_eval &block
      else
        unrooted_params[:user_id] = current_user.id
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
  
  # Rails raises an ArgumentError when assigning an invalid value to an enum
  # This is just stupid, so generate a rescuable exception with a helpful message instead
  def reraise_enum_errors(e)
    raise e unless e.message =~ /is not a valid/
    attribute = e.message.match(/is not a valid (\w+)/)[1]
    enum = model_class.send attribute.pluralize
    raise Talk::InvalidParameterError.new(attribute, "in #{ enum.keys }", unrooted_params[attribute])
  end
  
  def reraise_constantize_errors(e)
    if e.message =~ /wrong constant name/
      raise TalkService::ParameterError.new('Invalid type')
    else
      raise e
    end
  end
  
  def unauthorized!
    raise Pundit::NotAuthorizedError.new "not allowed to #{ action } this #{ model_class }"
  end
end
