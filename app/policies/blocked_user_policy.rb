class BlockedUserPolicy < ApplicationPolicy
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
    false
  end
  
  def destroy?
    owner?
  end
  
  class Scope < Scope
    def resolve
      scope.where user: user
    end
  end
end
