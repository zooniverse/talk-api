class CommentPolicy < ApplicationPolicy
  delegate :writable?, to: :discussion_policy

  def index?
    true
  end

  def show?
    discussion_policy.show?
  end

  def create?
    if Array.wrap(record).compact.any? { |c| c.discussion.board.section == 'zooniverse' }
      logged_in? && !locked? && writable? && confirmed? && of_posting_age?
    else
      logged_in? && !locked? && writable? && confirmed?
    end
  end

  def update?
    owner? && !deleted? && !locked? && writable? && confirmed?
  end

  def destroy?
    owner? && !deleted? && !locked? && writable? && confirmed?
  end

  def move?
    !locked? && !deleted? && (owner? || moderator? || admin?) && writable?
  end

  def upvote?
    logged_in? && !deleted? && !owner? && writable?
  end

  def remove_upvote?
    logged_in? && !deleted? && !owner? && writable?
  end

  def locked?
    discussions.any? &:locked?
  end

  def discussion_policy
    DiscussionPolicy.new user, discussions
  end

  def deleted?
    Array.wrap(record).compact.any? &:is_deleted?
  end

  def discussions
    @_discussions ||= Array.wrap(record).compact.collect(&:discussion).compact
  end

  class Scope < Scope
    delegate :zooniverse_admin?, :permissions, to: :@discussion_scope

    def initialize(user, scope)
      @discussion_scope = DiscussionPolicy::Scope.new user, Discussion
      super
    end

    def resolve
      return scope.all if zooniverse_admin?
      scope.joins(discussion: :board).where permissions.join(' or ')
    end

    def discussion_scope
      DiscussionPolicy::Scope.new user, Discussion
    end
  end
end
