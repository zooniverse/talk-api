class SuggestedTagPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    privileged?
  end

  def update?
    privileged?
  end

  def destroy?
    privileged?
  end

  def privileged?
    accessible_section? ['admin', 'moderator']
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
