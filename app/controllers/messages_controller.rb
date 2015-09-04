class MessagesController < ApplicationController
  include TalkResource
  disallow :update, :destroy
end
