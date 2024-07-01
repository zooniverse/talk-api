class ModerationsController < ApplicationController
  include TalkResource

  before_action :invert_enums, only: [:index], if: ->{ params.has_key? :state }

  def create
    service.create
    render json: serializer_class.resource({ id: service.resource.id }, nil, current_user: current_user, **sanitize_resource)
  end

  protected

  def sanitize_resource
    { }.tap do |list|
      %w(actioned_at actions created_at reports destroyed_target user_ip).each do |attr|
        list[:"include_#{ attr }?"] = false
      end
    end
  end

  def invert_enums
    return params.delete :state if params[:state] == 'all'
    inverted_state = Moderation.states[params[:state]]
    raise Talk::InvalidParameterError.new(:state, "in #{ Moderation.states.keys }", params[:state]) unless inverted_state
    params[:state] = inverted_state
  end
end
