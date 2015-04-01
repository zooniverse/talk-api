class BoardPolicy < ApplicationPolicy
  def index?
    true
  end
  
  def show?
    true
  end
  
  def create?
    moderator? || admin?
  end
  
  def update?
    moderator? || admin?
  end
  
  def destroy?
    moderator? || admin?
  end
  
  class Scope < Scope
    def resolve
      return scope.all if zooniverse_admin?
      scope.where permissions.join(' or ')
    end
    
    def permissions
      [for_all] + for_roles
    end
    
    def for_all
      "(permissions ->> 'read' = 'all')"
    end
    
    def for_roles
      user_roles.collect do |section, roles|
        roles << 'team' if team_for?(section)
        roles << 'moderator' if 'admin'.in?(roles)
        quoted_roles = roles.collect{ |role| quote role }.join ', '
        "(permissions ->> 'read' in (#{ quoted_roles }) and section = #{ quote section })"
      end
    end
    
    def team_for?(section)
      roles = user_roles[section] + user_roles.fetch('zooniverse', [])
      'admin'.in?(roles) || 'moderator'.in?(roles) || 'scientist'.in?(roles)
    end
    
    def zooniverse_admin?
      'admin'.in? user_roles.fetch('zooniverse', [])
    end
    
    def quote(string)
      ActiveRecord::Base.connection.quote string
    end
  end
end
