class MentionPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    board_policy.show?
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

  def board_policy
    BoardPolicy.new user, Array.wrap(record).compact.collect(&:board).compact
  end

  class Scope < Scope
    delegate :zooniverse_admin?, :permissions, to: :@board_scope

    def initialize(user, scope)
      @board_scope = BoardPolicy::Scope.new user, Board
      super
    end

    def resolve
      return scope.all if zooniverse_admin?
      scope.joins(:board).where permissions.join(' or ')
    end
  end
end
