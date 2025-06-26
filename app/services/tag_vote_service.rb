# frozen_string_literal: true

class TagVoteService < ApplicationService
  def build
    set_user
    super
  end
end
