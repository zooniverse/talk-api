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

  class Scope < Scope
    def resolve
      scope.joins(:conversation, :user_conversations).where({
        user_conversations: { user_id: user.id }
      })
    end
  end
end
