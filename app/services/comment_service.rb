class CommentService < ApplicationService
  def build
    set_user
    super
  end
end
