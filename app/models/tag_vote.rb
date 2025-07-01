# frozen_string_literal: true

class TagVote < ApplicationRecord
  belongs_to :user, required: true
  belongs_to :votable_tag, counter_cache: :vote_count, required: true, touch: true
  validates :user_id, uniqueness: { scope: :votable_tag_id }
end
