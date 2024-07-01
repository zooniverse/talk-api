class CommentsController < ApplicationController
  include TalkResource

  before_action :filter_subject_default, on: :index, if: ->{
    params.has_key?(:subject_default) && params[:section]
  }

  def upvote
    service.upvote
    render json: serializer_class.resource({ id: service.resource.id }, nil, current_user: current_user)
  end

  def remove_upvote
    service.remove_upvote
    render json: serializer_class.resource({ id: service.resource.id }, nil, current_user: current_user)
  end

  def destroy
    comment = Comment.find params[:id]
    authorize comment
    comment.soft_destroy
    render json: { }, status: :no_content
  end

  protected

  def filter_subject_default
    board_ids = Board.where(section: params[:section], subject_default: params[:subject_default]).pluck :id
    params[:board_id] = board_ids.join ','
    params.permit!
  end
end
