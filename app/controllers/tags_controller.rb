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
    params[:search].try :downcase!
    render json: {
      tags: cached_completion(required_param(:search), required_param(:section))
    }
  end

  def cached_completion(search, section)
    Rails.cache.fetch(completion_cache_key, expires_in: 1.hour) do
      TagCompletion.new(search, section, limit: 5).results
    end
  end

  def completion_cache_key
    "tag-completion-#{ params[:section] }-#{ params[:search] }"
  end
end
