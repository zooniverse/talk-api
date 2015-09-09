class GroupMention < ActiveRecord::Base
  belongs_to :comment, required: true
  belongs_to :user, required: true
  validates :section, presence: true
  validates :name, presence: true, inclusion: {
    in: %w(admins moderators researchers team),
    message: 'must be "admins", "moderators", "researchers", or "team"'
  }
  
  before_validation :denormalize_attributes, :downcase_name, on: :create
  after_commit :notify_later, on: :create
  
  def mentioned_users
    User.send name, on: section
  end
  
  def notify_later
    GroupMentionWorker.perform_async id
  end
  
  def notify_mentioned
    mentioned_users.each do |mentioned_user|
      mentioned_user.group_mentioned_by self
    end
  end
  
  def downcase_name
    self.name.try :downcase!
  end
  
  def denormalize_attributes
    self.user ||= comment.try(:user)
    self.section ||= comment.try(:section)
  end
end
