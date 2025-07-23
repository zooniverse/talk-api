# frozen_string_literal: true

class VotableTag < ApplicationRecord
  include Sectioned

  belongs_to :taggable, polymorphic: true
  validates :section, presence: true
  has_many :tag_votes, counter_cache: :vote_count
  validates :taggable_type, presence: true, if: -> { taggable_id.present? }
  validates :taggable_id, presence: true, if: -> { taggable_type.present? }

  def soft_destroy
    update! is_deleted: true
  end

  def create_vote
    TagVote.create(
      user_id: created_by_user_id,
      votable_tag_id: id
    )
  end
end
