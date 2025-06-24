class VotableTagPolicy < ApplicationPolicy
  def create?
    logged_in? && confirmed?
  end
end
