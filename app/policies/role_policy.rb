class RolePolicy < ApplicationPolicy
  def index?
    admin?
  end
  
  def show?
    accessible_section?
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
  
  concerning :PrivilegedSections do
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
  end
  
  class Scope < Scope
    include PrivilegedSections
    
    def resolve
      if !user
        scope.none
      elsif user.roles.where(section: 'zooniverse', name: 'admin').exists?
        scope.all
      else
        scope.where 'section = any(array[:sections])', sections: privileged_sections
      end
    end
  end
end
