class ConversationPolicy < ApplicationPolicy
  def index?
    logged_in? && confirmed?
  end

  def show?
    (moderator? || admin? || participant?) && confirmed?
  end

  def create?
    logged_in? && confirmed?
  end

  def update?
    false
  end

  def destroy?
    participant? && confirmed?
  end

  class Scope < Scope
    def resolve
      scope.for_user user
    end
  end
end
