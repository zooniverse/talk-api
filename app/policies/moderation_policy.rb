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
      if zooniverse_roles.any?
        scope
      else
        scope.where 'section = any(array[:sections])', sections: privileged_sections
      end
    end
    
    def privileged_sections
      user.roles.select do |section, roles|
        'moderator'.in?(roles) || 'admin'.in?(roles)
      end.keys
    end
  end
end
