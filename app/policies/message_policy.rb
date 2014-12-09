class MessagePolicy < ApplicationPolicy
  def index?
    participant?
  end
  
  def show?
    moderator? || admin? || participant?
  end
  
  def create?
    participant?
  end
  
  def update?
    false
  end
  
  def destroy?
    false
  end
  
  class Scope < Scope
    def resolve
      scope.joins(:conversation, :user_conversations).where({
        user_conversations: { user_id: user.id }
      })
    end
  end
end
