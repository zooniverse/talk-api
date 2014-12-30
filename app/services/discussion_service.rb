class DiscussionService < ApplicationService
  def build
    set_user if action == :create
    @resource = model_class.new(discussion_params).tap do |discussion|
      discussion.comments << CommentService.new({
        params: comment_params,
        action: :create,
        current_user: current_user
      }).build
    end
  end
  
  def discussion_params
    unrooted_params.except :comments
  end
  
  def comment_params
    ActionController::Parameters.new({
      comments: unrooted_params[:comments].first
    })
  rescue
    ActionController::Parameters.new
  end
end
