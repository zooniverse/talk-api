class UnsubscribeController < ApplicationController
  before_action :permit_params
  skip_before_action :set_format, :enforce_ban, :enforce_ip_ban

  def index
    if current_user
      SubscriptionPreference.for_user(current_user).values.each do |preference|
        preference.update email_digest: never
      end
    end

    log_event! 'unsubscribe', ip: current_user_ip
  end

  def current_user
    @current_user ||= UnsubscribeToken.find_by_token(params[:token]).try(:user)
  end

  def never
    SubscriptionPreference.email_digests[:never]
  end

  def permit_params
    params.permit :token
  end

  def log_event!(label, payload)
    EventLog.create label: label, user_id: current_user.try(:id), payload: payload
  end
end
