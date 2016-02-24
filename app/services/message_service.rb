class MessageService < ApplicationService
  def build
    set_user

    super.tap do |built|
      built.user_ip = user_ip
      raise Talk::BlockedUserError.new if blocked?
      raise Talk::UserBlockedError.new if blocking?
    end
  end

  def blocked?
    return false unless resource.conversation
    BlockedUser.blocked_by(recipient_ids).blocking(current_user.id).exists?
  end

  def blocking?
    return false unless resource.conversation
    BlockedUser.blocked_by(current_user.id).blocking(recipient_ids).exists?
  end

  def recipient_ids
    resource.conversation.participant_ids - [current_user.id]
  end
end
