# frozen_string_literal: true

class VotableTag < ApplicationRecord
  include Sectioned

  belongs_to :taggable, polymorphic: true
  validates :section, presence: true
  has_many :tag_votes, counter_cache: :vote_count
  validates :taggable_type, presence: true, if: -> { taggable_id.present? }
  validates :taggable_id, presence: true, if: -> { taggable_type.present? }
end
