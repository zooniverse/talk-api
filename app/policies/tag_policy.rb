class TagPolicy < ApplicationPolicy
  def index?
    true
  end
  
  def show?
    true
  end
  
  def create?
    false
  end
  
  def update?
    false
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
