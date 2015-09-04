class SubscriptionsController < ApplicationController
  include TalkResource
  disallow :destroy
end
