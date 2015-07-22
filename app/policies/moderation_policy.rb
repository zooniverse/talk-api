class ModerationPolicy < ApplicationPolicy
  def index?
    logged_in?
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
    @available_actions ||= target.class.moderatable.select do |action, roles|
      roles[:all] ||
      (roles[:moderator] && moderator?) ||
      (roles[:admin] && admin?) ||
      (roles[:team] && team?)
    end.keys
  end
  
  def target
    record.target || (raise ActiveRecord::RecordNotFound.new("Couldn't find target"))
  end
  
  class Scope < Scope
    def resolve
      if user.roles.where(section: 'zooniverse', name: ['moderator', 'admin']).any?
        scope
      elsif privileged_sections.any?
        scope.where 'section = any(array[:sections])', sections: privileged_sections
      else
        scope.none
      end
    end
  end
end
