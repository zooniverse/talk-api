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
      Array.wrap(record).each do |record|
        return false unless record.users.exists?(id: user.id)
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
      @_roles = user.roles.where(scope: sections).collect(&:name).uniq
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
        @_roles[role.scope] ||= []
        @_roles[role.scope] << role.name
      end
      @_roles
    end
  end
end
