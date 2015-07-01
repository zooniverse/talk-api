module ActionRescuing
  extend ActiveSupport::Concern
  
  included do
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActiveRecord::UnknownAttributeError, with: :unprocessable
    rescue_from ActionController::UnpermittedParameters, with: :unprocessable
    rescue_from TalkService::ParameterError, with: :unprocessable
    rescue_from ActionController::RoutingError, with: :not_found
    
    rescue_from Pundit::AuthorizationNotPerformedError, with: :not_implemented
    rescue_from Pundit::PolicyScopingNotPerformedError, with: :not_implemented
    rescue_from Pundit::NotDefinedError, with: :not_implemented
    rescue_from Pundit::NotAuthorizedError, with: :unauthorized
    rescue_from ActiveRecord::RecordNotDestroyed, with: :unauthorized
    
    rescue_from JSON::Schema::ValidationError, with: :unprocessable
    rescue_from ActionController::ParameterMissing, with: :unprocessable
    rescue_from Talk::BannedUserError, with: :forbidden
  end
  
  def unauthorized(exception)
    render_exception :unauthorized, exception
  end
  
  def forbidden(exception)
    render_exception :forbidden, exception
  end
  
  def not_found(exception)
    render_exception :not_found, exception
  end
  
  def unprocessable(exception)
    render_exception :unprocessable_entity, exception
  end
  
  def not_implemented(exception)
    render_exception :not_implemented, exception
  end
  
  def render_exception(status, exception)
    self.response_body = nil
    render status: status, json: { error: exception.message }
  end
end
