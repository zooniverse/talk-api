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
    records = Array.wrap record
    return false if records.length > 1
    logged_in? && user.id == records.first.id
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
