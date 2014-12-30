class ModerationService < ApplicationService
  def initialize(*args)
    super
    set_reporting_user if action == :create
  end
  
  def set_reporting_user
    set_user do
      unrooted_params[:reports].each do |report|
        report[:user_id] = current_user.id
      end
    end
  end
end
