class UsersController < ApplicationController
  include TalkResource
  disallow :create, :update, :destroy

  def autocomplete
    require_user!
    render json: {
      usernames: UsernameCompletion.new(current_user, required_param(:search)).results
    }
  end
end
