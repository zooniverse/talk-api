require 'pundit'
require 'pundit/not_authorized_error'

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
      return false unless logged_in?
      return true if roles_in('zooniverse').include?(role)
      record_sections.each do |section|
        roles = roles_in section
        return false if roles.empty? || !roles.include?(role)
      end
      true
    end

    def confirmed?
      !!user.confirmed_at
    end

    def of_posting_age?
      return true unless ENV['POSTING_AGE_REQUIREMENT']

      user.created_at < (Time.now - age_requirement)
    end

    def age_requirement
      quant = ENV.fetch('POSTING_AGE_REQUIREMENT', '24')
      quant.to_i.hours
    end

    def roles_in(section)
      user_roles.fetch section, []
    end

    def user_roles
      return @_roles if @_roles
      return { } unless logged_in?
      @_roles = { }
      sections = (record_sections + ['zooniverse']).uniq
      user.roles.where(section: sections).each do |role|
        @_roles[role.section] ||= []
        @_roles[role.section] << role.name
      end
      @_roles
    end

    def record_sections
      sections = Array.wrap(record).collect do |r|
        r.section if r.respond_to?(:section)
      end.compact.uniq
      sections.empty? ? ['zooniverse'] : sections
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
    Pundit.policy_scope!(user, Array.wrap(record).first.class)
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
