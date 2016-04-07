class RolePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    accessible_section?
  end

  def update?
    accessible_section?
  end

  def destroy?
    accessible_section?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
