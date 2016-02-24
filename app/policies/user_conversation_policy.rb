class UserConversationPolicy < ApplicationPolicy
  def index?
    logged_in?
  end

  def show?
    moderator? || admin? || owner?
  end

  def create?
    logged_in?
  end

  def update?
    owner?
  end

  def destroy?
    owner?
  end

  class Scope < Scope
    def resolve
      scope.where user_id: user.id
    end
  end
end
