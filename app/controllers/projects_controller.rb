class ProjectsController < ApplicationController
  include TalkResource
  disallow :create, :update, :destroy
end
