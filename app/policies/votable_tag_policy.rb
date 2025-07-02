# frozen_string_literal: true

class VotableTagPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    logged_in? && confirmed?
  end

  def update?
    logged_in? && confirmed?
  end

  class Scope < Scope
    def resolve
      return scope.all if zooniverse_admin?

      scope.where(is_deleted: false)
    end
  end
end
