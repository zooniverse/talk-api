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
  
  def can_action?(action)
    available_actions.include? action.to_sym
  end
  
  def available_actions
    return [] unless logged_in?
    @available_actions ||= record.target.class.moderatable.select do |action, roles|
      roles[:all] ||
      (roles[:moderator] && moderator?) ||
      (roles[:admin] && admin?) ||
      (roles[:team] && team?)
    end.keys
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
