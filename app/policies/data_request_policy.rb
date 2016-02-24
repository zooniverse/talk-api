class DataRequestPolicy < ApplicationPolicy
  def index?
    logged_in?
  end

  def show?
    zooniverse_admin? || owner?
  end

  def create?
    accessible_section?
  end

  def update?
    false
  end

  def destroy?
    false
  end

  class Scope < Scope
    def resolve
      zooniverse_admin? ? scope.all : scope.where(user_id: user.id)
    end
  end
end
