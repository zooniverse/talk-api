class ApplicationPolicy
  attr_reader :user, :record
  
  def initialize(user, record)
    @user = user
    @record = record
  end
  
  def index?
    true
  end
  
  def show?
    true
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
  
  concerning :UserPredicates do
    def logged_in?
      !!user
    end
    
    def owner?
      logged_in? && Array.wrap(record).all?{ |r| user.id == r.user_id }
    end
    
    # TO-DO: refactor to use an ALL query
    def participant?
      return false unless logged_in?
      Array.wrap(record).each do |r|
        return false unless r.users.exists?(id: user.id)
      end
      true
    end
    
    def moderator?
      has_role? 'moderator'
    end
    
    def admin?
      has_role? 'admin'
    end
    
    def scientist?
      has_role? 'scientist'
    end
    
    def zooniverse_admin?
      logged_in? && user.roles.where(section: 'zooniverse', name: 'admin').exists?
    end
    
    def team?
      moderator? || admin? || scientist?
    end
    
    def has_role?(role)
      logged_in? && role.in?(user_roles)
    end
    
    def user_roles
      return @_roles if @_roles
      return [] unless logged_in?
      sections = ['zooniverse']
      sections += [record.section] if record.respond_to?(:section)
      @_roles = user.roles.where(section: sections).collect(&:name).uniq
    end
    
    def privileged_sections(*roles)
      return [] unless user
      @privileged_sections ||= { }
      @privileged_sections[roles] ||= user.roles.where(name: roles).distinct(:section).pluck(:section)
    end
    
    def accessible_section?(roles = ['admin'])
      return true if zooniverse_admin?
      Array.wrap(record).each do |r|
        return false unless privileged_sections(*roles).include?(r.section)
      end
      true
    end
  end
  
  def scope
    Pundit.policy_scope!(user, record.class)
  end
  
  class Scope
    include UserPredicates
    attr_reader :user, :scope
    
    def initialize(user, scope)
      @user = user
      @scope = scope
    end
    
    def resolve
      scope
    end
    
    def user_roles
      return @_roles if @_roles
      return { } unless logged_in?
      @_roles = { }
      user.roles.each do |role|
        @_roles[role.section] ||= []
        @_roles[role.section] << role.name
      end
      @_roles
    end
  end
end
