class TagsController < ApplicationController
  include TalkResource
  disallow :create, :update, :destroy

  def popular
    params[:name].try :downcase!
    render json: popular_serializer.resource(params, nil, current_user: current_user)
  end

  def popular_serializer
    if params[:taggable_id] || params[:taggable_type]
      PopularFocusTagSerializer
    else
      PopularTagSerializer
    end
  end

  def autocomplete
    render json: {
      tags: TagCompletion.new(required_param(:search), required_param(:section)).results
    }
  end
end
