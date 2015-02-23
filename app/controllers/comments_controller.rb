class CommentsController < ApplicationController
  include TalkResource
  
  def upvote
    service.upvote
    render json: serializer_class.resource(service.resource)
  end
  
  def remove_upvote
    service.remove_upvote
    render json: serializer_class.resource(service.resource)
  end
  
  def destroy
    comment = Comment.find params[:id]
    authorize comment
    comment.soft_destroy
    render json: { }, status: :no_content
  end
end
