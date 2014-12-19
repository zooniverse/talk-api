class Moderation < ActiveRecord::Base
  belongs_to :target, polymorphic: true, required: true
  
  validates :section, presence: true
  
  before_update :transition_state
  
  enum state: {
    opened: 0,
    ignored: 1,
    closed: 2,
    logged: 3,
    watched: 4
  }
  
  protected
  
  def transition_state
    self.actioned_at = Time.now.utc if state_changed?
  end
end
