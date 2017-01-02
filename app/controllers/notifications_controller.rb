class NotificationsController < ApplicationController
  include TalkResource
  disallow :create, :destroy

  def read
    require_user!
    scoped = reading_scope
    scoped.update_all delivered: true
    params[:sort] ||= serializer_class.default_sort if serializer_class.default_sort
    render json: serializer_class.page(params, scoped, current_user: current_user)
  end

  def reading_scope
    scoped = policy_scope model_class

    if resource_ids.any?
      scoped = scoped.where id: resource_ids
    elsif section = params[:section]
      scoped = scoped.where section: section
    end

    scoped
  end
end
