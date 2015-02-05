class Tag < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :comment, required: true
  belongs_to :taggable, polymorphic: true
  validates :section, presence: true
  
  before_validation :propagate_values, on: :create
  
  scope :in_section, ->(section){ where section: section }
  scope :of_type, ->(type){ where taggable_type: type.classify }
  scope :popular, ->(limit: 10){ group(:name).order('count_all desc').limit(limit).count :all }
  
  def propagate_values
    return unless comment
    self.section = comment.section
    self.user = comment.user
    self.taggable = comment.focus
    self.taggable_type = comment.focus.class if comment.focus
  end
end
