class CommentPolicy < ApplicationPolicy
  delegate :locked?, to: 'record.discussion'
  
  def index?
    true
  end
  
  def show?
    true
  end
  
  def create?
    logged_in? && !locked?
  end
  
  def update?
    owner? && !locked?
  end
  
  def destroy?
    owner? && !locked?
  end
  
  def move?
    !locked? && (owner? || moderator? || admin?)
  end
  
  def upvote?
    logged_in? && !owner?
  end
  
  class Scope < Scope
    def resolve
      scope
    end
  end
end
