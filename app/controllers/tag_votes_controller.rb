class TagVotesController < ApplicationController
  include TalkResource
  def destroy
    vote = TagVote.find params[:id]
    votable_tag_id = vote.votable_tag_id
    super

    votable_tag = VotableTag.find(votable_tag_id)
    votable_tag.soft_destroy if votable_tag.vote_count.zero?
  end
end
