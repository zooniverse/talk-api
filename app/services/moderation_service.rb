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
    set_user_on(:actions) if unrooted_params[:actions]
    super
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
