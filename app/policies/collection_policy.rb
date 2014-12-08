class CollectionPolicy < ApplicationPolicy
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
    owner?
  end
  
  def destroy?
    owner?
  end
  
  class Scope < Scope
    def resolve
      scope
    end
  end
end
