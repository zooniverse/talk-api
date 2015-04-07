class Moderation < ActiveRecord::Base
  belongs_to :target, polymorphic: true
  validates :target, presence: true, on: :create
  validates :section, presence: true
  
  before_update :reopen, if: :reports_changed?
  before_update :apply_action, if: :actions_changed?
  
  enum state: {
    opened: 0,
    ignored: 1,
    closed: 2,
    watched: 3
  }
  
  protected
  
  def apply_action
    self.actioned_at = Time.now.utc
    case actions.last.with_indifferent_access[:action]
    when 'destroy'
      destroy_target
    when 'ignore'
      ignore_target
    when 'watch'
      watch_target
    end
  end
  
  def reopen
    self.state = 'opened'
  end
  
  def destroy_target
    self.state = 'closed'
    target.destroy!
    self.target = nil
  end
  
  def ignore_target
    self.state = 'ignored'
  end
  
  def watch_target
    self.state = 'watched'
  end
end
