class MessagePolicy < ApplicationPolicy
  def index?
    logged_in? && confirmed?
  end

  def show?
    (moderator? || admin? || participant?) && confirmed?
  end

  def create?
    participant? && confirmed?
  end

  def update?
    false
  end

  def destroy?
    false
  end

  def participant?
    return false unless logged_in?
    Array.wrap(record).each do |r|
      if r.persisted?
        return r.users.exists?(id: user.id)
      elsif r.conversation
        return r.conversation.users.exists?(id: user.id)
      end
      return false
    end
    true
  end

  class Scope < Scope
    def resolve
      scope.joins(:conversation, :user_conversations).where({
        user_conversations: { user_id: user.id }
      })
    end
  end
end
