class ModerationsController < ApplicationController
  include TalkResource
  
  before_action :invert_enums, only: [:index], if: ->{ params.has_key? :state }
  
  def invert_enums
    inverted_state = Moderation.states[params[:state]]
    raise Talk::InvalidParameterError.new(:state, "in #{ Moderation.states.keys }", params[:state]) unless inverted_state
    params[:state] = inverted_state
  end
end
