# frozen_string_literal: true

class TagVotesController < ApplicationController
  include TalkResource
  disallow :update

  def destroy
    vote = TagVote.find params[:id]
    authorize vote
    votable_tag = vote.votable_tag

    TagVote.transaction do
      votable_tag.lock!
      vote.destroy!
      votable_tag.reload
      votable_tag.soft_destroy if votable_tag.vote_count.zero?
    end
    render json: {}, status: :no_content
  end
end
