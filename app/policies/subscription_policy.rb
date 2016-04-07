class SubscriptionPolicy < ApplicationPolicy
  def index?
    logged_in?
  end

  def show?
    owner?
  end

  def create?
    logged_in?
  end

  def update?
    owner?
  end

  def destroy?
    false
  end

  class Scope < Scope
    def resolve
      scope.where user: user
    end
  end
end
