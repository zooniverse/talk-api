class ModerationPolicy < ApplicationPolicy
  def index?
    moderator? || admin?
  end
  
  def show?
    moderator? || admin?
  end
  
  def create?
    logged_in?
  end
  
  def update?
    moderator? || admin?
  end
  
  def destroy?
    moderator? || admin?
  end
  
  class Scope < Scope
    def resolve
      if user.roles.where(scope: 'zooniverse', name: ['moderator', 'admin']).any?
        scope
      else
        scope.where 'section = any(array[:sections])', sections: privileged_sections
      end
    end
    
    def privileged_sections
      user.roles.where(name: ['moderator', 'admin']).distinct(:scope).pluck :scope
    end
  end
end
