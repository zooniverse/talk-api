# frozen_string_literal: true

class TagVotesController < ApplicationController
  include TalkResource
  disallow :update

  def create
    service.build unless service.resource
    votable_tag = VotableTag.find service.unrooted_params[:votable_tag_id]
    TagVote.transaction do
      votable_tag.lock!
      votable_tag.reload
      service.authorize unless service.authorized?
      service.validate unless service.validated?
      service.resource.save!
    end
    render json: serializer_class.resource({ id: service.resource.id }, nil, current_user:)
  end

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
