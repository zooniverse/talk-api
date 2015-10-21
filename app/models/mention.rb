class Mention < ActiveRecord::Base
  include Sectioned
  
  belongs_to :comment, required: true
  belongs_to :user, required: true
  belongs_to :mentionable, polymorphic: true, required: true
  
  before_save :set_section, :set_project_id
  after_commit :notify_later, on: :create
  
  def set_section
    self.section = comment.section
  end
  
  def notify_later
    MentionWorker.perform_async id
  end
  
  def notify_mentioned
    mentionable.mentioned_by comment
  end
end
