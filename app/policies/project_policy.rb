class ProjectPolicy < ApplicationPolicy
  def show?
    !private?
  end

  def private?
    Array.wrap(record).any? &:private?
  end

  class Scope < Scope
    def initialize(user, scope)
      @board_scope = BoardPolicy::Scope.new user, Board
      super
    end

    # Only find public, launch approved projects with boards
    def resolve
      scope
        .where(launch_approved: true)
        .where('private is not true')
        .joins(:boards)
        .order(launched_row_order: :desc)
        .distinct
    end
  end
end
