class BoardPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    readable?
  end

  def create?
    moderator? || admin?
  end

  def update?
    (moderator? || admin?) && writable?
  end

  def destroy?
    (moderator? || admin?) && writable?
  end

  def readable?
    return false unless board_ids.compact.present?
    ReadableScope.new(user, Board.where(id: board_ids)).resolve.pluck(:id).sort == board_ids.sort
  end

  def writable?
    return false unless board_ids.compact.present? && logged_in?
    WritableScope.new(user, Board.where(id: board_ids)).resolve.pluck(:id).sort == board_ids.sort
  end

  def board_ids
    Array.wrap(record).compact.collect &:id
  end

  class PermissionsScope < Scope
    def resolve
      return scope.all if zooniverse_admin?
      scope.where permissions.join(' or ')
    end

    def permissions
      [for_all] + for_roles
    end

    def for_all
      "(boards.permissions ->> '#{ @permission }' = 'all')"
    end

    def for_roles
      user_roles.collect do |section, roles|
        roles << 'translator' if translator_for?(roles)
        roles << 'team' if team_for?(section)
        roles << 'moderator' if 'admin'.in?(roles) # admin is the owner role for the section
        quoted_roles = roles.uniq.collect{ |role| quote role }.join ', '
        "(boards.permissions ->> '#{ @permission }' in (#{ quoted_roles }) and boards.section = #{ quote section })"
      end
    end

    def translator_for?(roles)
      'admin'.in?(roles) || 'moderator'.in?(roles) || 'scientist'.in?(roles) || 'translator'.in?(roles)
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

  class ReadableScope < PermissionsScope
    def initialize(user, scope)
      @permission = :read
      super
    end
  end

  class WritableScope < PermissionsScope
    def initialize(user, scope)
      @permission = :write
      super
    end
  end

  class Scope < ReadableScope
  end
end
