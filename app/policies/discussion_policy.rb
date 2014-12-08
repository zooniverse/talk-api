class DiscussionPolicy < ApplicationPolicy
  def index?
    true
  end
  
  def show?
    true
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
