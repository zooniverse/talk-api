class DataRequestsController < ApplicationController
  include TalkResource
  disallow :update, :destroy
end
