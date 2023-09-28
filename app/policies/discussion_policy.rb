class DiscussionPolicy < ApplicationPolicy
  delegate :writable?, to: :board_policy

  def index?
    true
  end

  def show?
    board_policy.show?
  end

  def create?
    if Array.wrap(record).compact.any? { |d| d.board.section == 'zooniverse' }
      writable? && of_posting_age?
    else
      writable?
    end
  end

  def update?
    (owner? || moderator? || admin?) && writable?
  end
  alias_method :owner_update?, :update?

  def destroy?
    (moderator? || admin?) && writable?
  end

  def board_policy
    BoardPolicy.new user, boards
  end

  def boards
    Array.wrap(record).compact.collect &:board
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

    def board_scope
      BoardPolicy::Scope.new user, Board
    end
  end
end
