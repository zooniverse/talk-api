# frozen_string_literal: true

class VotableTagsController < ApplicationController
  include TalkResource
  disallow :destroy, :update

  def index
    params[:name].try :downcase!
    super
  end

  def create
    service.create
    service.resource.create_vote
    render json: serializer_class.resource({ id: service.resource.id }, nil, current_user:)
  end
end
