class ConversationPolicy < ApplicationPolicy
  def index?
    logged_in?
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
  
  class Scope < Scope
    def resolve
      scope.joins(:user_conversations).where({
        user_conversations: { user_id: user.id }
      })
    end
  end
end
