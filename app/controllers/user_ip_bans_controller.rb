class UserIpBansController < ApplicationController
  include TalkResource
  disallow :update
end
