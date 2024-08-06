class SuggestedTag < ApplicationRecord
  validates :section, presence: true
  validates :name, presence: true, length: {
    minimum: 3,
    maximum: 40
  }, uniqueness: {
    scope: :section,
    message: 'Suggested tag already exists for this section'
  }

  before_save :normalize_name

  def normalize_name
    self.name = name.downcase.gsub /[^\-\w\d]/, ''
  end
end
