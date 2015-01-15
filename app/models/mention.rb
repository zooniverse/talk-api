class Mention < ActiveRecord::Base
  belongs_to :comment, required: true
  belongs_to :user, required: true
  belongs_to :mentionable, polymorphic: true, required: true
  
  after_create :notify_mentioned
  
  def notify_mentioned
    mentionable.mentioned_by comment
  end
end
