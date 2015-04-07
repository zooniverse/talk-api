class ModerationService < ApplicationService
  def build
    set_user_on :reports
    existing_resource ? add_report : super
  end
  
  def add_report
    new_report = unrooted_params.fetch :reports, []
    unrooted_params[:reports] = resource.reports + new_report
    update_resource
  end
  
  def update_resource
    set_user_on(:actions) if actioning?
    super
  end
  
  def authorize
    build unless resource
    @authorized = policy.send "#{ action }?"
    @authorized &= actioning? && can_action? if updating?
    unauthorized! unless authorized?
  end
  
  def updating?
    action == :update
  end
  
  def actioning?
    updating? && unrooted_params[:actions].is_a?(Array)
  end
  
  def can_action?
    moderation_action = unrooted_params[:actions].first || { }
    policy.can_action? moderation_action.fetch('action', '')
  end
  
  protected
  
  def existing_resource
    @resource = Moderation.find_by_target_id unrooted_params[:target_id]
  end
  
  def set_user_on(key)
    set_user do
      unrooted_params[key].each do |embedded|
        embedded[:user_id] = current_user.id
      end
    end
  end
end
