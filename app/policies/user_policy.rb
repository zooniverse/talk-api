class UserPolicy < ApplicationPolicy
  def index?
    logged_in?
  end
  
  def show?
    true
  end
  
  def create?
    false
  end
  
  def update?
    logged_in? && user.id == record.id
  end
  
  def destroy?
    false
  end
  
  class Scope < Scope
    def resolve
      scope
    end
  end
end
