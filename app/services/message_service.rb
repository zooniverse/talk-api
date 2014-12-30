class MessageService < ApplicationService
  def build
    set_user if action == :create
    super
  end
end
