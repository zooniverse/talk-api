class UsersController < ApplicationController
  include TalkResource
  disallow :create, :update, :destroy

  def autocomplete
    require_user!
    params[:search].try :downcase!
    render json: {
      usernames: cached_completion(required_param(:search))
    }
  end

  def cached_completion(search)
    Rails.cache.fetch(completion_cache_key, expires_in: 1.hour) do
      UsernameCompletion.new(current_user, required_param(:search), limit: 5).results
    end
  end

  def completion_cache_key
    "username-completion-#{ current_user.id }-#{ params[:search] }"
  end
end
