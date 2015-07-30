class TagPolicy < ApplicationPolicy
  def index?
    true
  end
  
  def popular?
    true
  end
  
  def show?
    comment_policy.show?
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
  
  def comment_policy
    CommentPolicy.new user, comments
  end
  
  def comments
    Array.wrap(record).compact.collect &:comment
  end
  
  class Scope < Scope
    delegate :zooniverse_admin?, :permissions, to: :@comment_scope
    
    def initialize(user, scope)
      @comment_scope = CommentPolicy::Scope.new user, Comment
      super
    end
    
    def resolve
      return scope.all if zooniverse_admin?
      scope.joins(comment: { discussion: :board }).where permissions.join(' or ')
    end
    
    def comment_scope
      CommentPolicy::Scope.new user, Comment
    end
  end
end
