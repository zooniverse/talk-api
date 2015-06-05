class RolePolicy < ApplicationPolicy
  def index?
    true
  end
  
  def show?
    true
  end
  
  def create?
    accessible_section?
  end
  
  def update?
    accessible_section?
  end
  
  def destroy?
    accessible_section?
  end
  
  def privileged_sections
    return [] unless user
    @privileged_sections ||= user.roles.where(name: 'admin').distinct(:section).pluck :section
  end
  
  def accessible_section?
    return true if privileged_sections.include?('zooniverse')
    Array.wrap(record).each do |r|
      return false unless privileged_sections.include?(r.section)
    end
    true
  end
  
  class Scope < Scope
    def resolve
      scope
    end
  end
end
