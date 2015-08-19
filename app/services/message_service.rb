class MessageService < ApplicationService
  def build
    set_user
    super.tap do |built|
      built.user_ip = user_ip
    end
  end
end
