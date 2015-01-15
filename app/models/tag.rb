class Tag < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :comment, required: true
  belongs_to :taggable, polymorphic: true
  validates :section, presence: true
  
  before_validation :propagate_values, on: :create
  
  def propagate_values
    return unless comment
    self.section = comment.section
    self.user = comment.user
    self.taggable = comment.focus
  end
end
