# frozen_string_literal: true

class TagVotePolicy < ApplicationPolicy
  def create?
    record.user_id == user.id && logged_in? && confirmed? && !record.votable_tag&.is_deleted
  end

  def destroy?
    record.user_id == user.id && logged_in? && confirmed?
  end
end
