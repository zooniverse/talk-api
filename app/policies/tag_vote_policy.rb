# frozen_string_literal: true

class TagVotePolicy < ApplicationPolicy
  def create?
    logged_in? && confirmed? && record.user_id == user.id && !record.votable_tag&.is_deleted
  end

  def destroy?
    logged_in? && confirmed? && record.user_id == user.id
  end
end
