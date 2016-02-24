class CommentService < ApplicationService
  def build
    set_user
    super.tap do |built|
      built.user_ip = user_ip
    end
  end

  def upvote
    find_and_authorize
    resource.upvote! current_user
  end

  def remove_upvote
    find_and_authorize
    resource.remove_upvote! current_user
  end

  protected

  def find_and_authorize
    find_resource unless resource
    authorize unless authorized?
  end
end
