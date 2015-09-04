class UsersController < ApplicationController
  include TalkResource
  disallow :create, :update, :destroy
end
