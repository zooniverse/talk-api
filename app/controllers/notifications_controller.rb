class NotificationsController < ApplicationController
  include TalkResource
  disallow :create, :destroy

  def read
    require_user!
    scoped = policy_scope model_class
    scoped = scoped.where(id: resource_ids) if resource_ids.any?
    scoped.update_all delivered: true
    params[:sort] ||= serializer_class.default_sort if serializer_class.default_sort
    render json: serializer_class.page(params, scoped, current_user: current_user)
  end
end
