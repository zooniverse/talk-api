class CommentService < ApplicationService
  def initialize(*args)
    super
    set_user if action == :create
  end
end
