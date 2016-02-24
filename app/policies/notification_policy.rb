class NotificationPolicy < ApplicationPolicy
  def index?
    logged_in?
  end

  def show?
    owner?
  end

  def create?
    false
  end

  def update?
    owner?
  end

  def destroy?
    false
  end

  class Scope < Scope
    def resolve
      scope.where user_id: user.id
    end
  end
end
