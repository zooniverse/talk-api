class MentionsController < ApplicationController
  include TalkResource
  disallow :create, :update, :destroy
end
