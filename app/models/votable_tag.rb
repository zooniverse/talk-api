class VotableTag < ApplicationRecord
  include Sectioned

  belongs_to :taggable, polymorphic: true
  validates :section, presence: true

  
end
