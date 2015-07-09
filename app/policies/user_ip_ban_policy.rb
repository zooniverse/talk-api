class UserIpBanPolicy < ApplicationPolicy
  def index?
    zooniverse_admin?
  end
  
  def show?
    zooniverse_admin?
  end
  
  def create?
    zooniverse_admin?
  end
  
  def update?
    false
  end
  
  def destroy?
    zooniverse_admin?
  end
  
  class Scope < Scope
    def resolve
      zooniverse_admin? ? scope.all : scope.none
    end
  end
end
