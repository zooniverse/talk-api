class NotificationsController < ApplicationController
  include TalkResource
  disallow :create, :destroy
end
