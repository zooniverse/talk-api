class ModerationPolicy < ApplicationPolicy
  def index?
    moderator? || admin?
  end
  
  def show?
    moderator? || admin?
  end
  
  def create?
    logged_in?
  end
  
  def update?
    moderator? || admin?
  end
  
  def destroy?
    moderator? || admin?
  end
  
  class Scope < Scope
    def resolve
      scope
    end
  end
end
