class MessagePolicy < ApplicationPolicy
  def index?
    logged_in? && confirmed?
  end

  def show?
    (moderator? || admin? || participant?) && confirmed?
  end

  def create?
    participant? && confirmed?
  end

  def update?
    false
  end

  def destroy?
    false
  end

  def participant?
    return false unless logged_in?
    Array.wrap(record).each do |r|
      if r.persisted?
        return r.users.exists?(id: user.id)
      elsif r.conversation
        return r.conversation.users.exists?(id: user.id)
      end
      return false
    end
    true
  end

  class Scope < Scope
    def resolve
      # TODO: REMOVE VERSION CHECK ONCE ON RAILS 6.1
      # Rails 6.1 introduces a feature that allows .where
      # to access alias tables.
      # See: https://blog.saeloun.com/2021/01/25/rails-6-allow-where-clause-reference-association-by-alias-name/
      # This change is not backwards compatible with Rails 6.0

      if Rails.version.starts_with?('6.0')
        scope.joins(:conversation, :user_conversations).where({
        user_conversations: { user_id: user.id }
        })
      else
        scope.joins(:conversation, :user_conversations).where({
        user_conversations_messages: { user_id: user.id }
        })
      end
    end
  end
end
