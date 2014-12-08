class ConversationPolicy < ApplicationPolicy
  def index?
    participant?
  end
  
  def show?
    moderator? || admin? || participant?
  end
  
  def create?
    logged_in?
  end
  
  def update?
    false
  end
  
  def destroy?
    false
  end
  
  def participant?
    logged_in? && record.users.exists?(id: user.id)
  end
  
  class Scope < Scope
    def resolve
      scope.joins(:user_conversations).where({
        user_conversations: { user_id: user.id }
      })
    end
  end
end
