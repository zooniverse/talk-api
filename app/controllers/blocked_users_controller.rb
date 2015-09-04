class BlockedUsersController < ApplicationController
  include TalkResource
  disallow :update
end
