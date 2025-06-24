# frozen_string_literal: true

class VotableTag < ApplicationRecord
  include Sectioned

  belongs_to :taggable, polymorphic: true
  validates :section, presence: true
  has_many :tag_votes
end
