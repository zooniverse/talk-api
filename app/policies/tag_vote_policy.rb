# frozen_string_literal: true

class TagVotePolicy < ApplicationPolicy
  def create?
    record.user_id == user.id && logged_in? && confirmed?
  end

  def destroy?
    record.user_id == user.id && logged_in? && confirmed?
  end
end
