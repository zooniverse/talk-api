# frozen_string_literal: true

class VotableTag < ApplicationRecord
  include Sectioned

  belongs_to :taggable, polymorphic: true
  validates :name, presence: true
  validates :section, presence: true
  has_many :tag_votes, counter_cache: :vote_count
  validates :taggable_type, presence: true, if: -> { taggable_id.present? }
  validates :taggable_id, presence: true, if: -> { taggable_type.present? }
  validate :name_cannot_contain_spaces
  before_save :downcase_name

  def soft_destroy
    update! is_deleted: true
  end

  def create_vote
    TagVote.create(
      user_id: created_by_user_id,
      votable_tag_id: id
    )
  end

  private

  def name_cannot_contain_spaces
    errors.add(:name, 'cannot contain spaces') if name.present? && name.include?(' ')
  end

  def downcase_name
    name.downcase!
  end
end
