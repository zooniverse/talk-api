# frozen_string_literal: true

class VotableTagsController < ApplicationController
  include TalkResource
  disallow :destroy
end
