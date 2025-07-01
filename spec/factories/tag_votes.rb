# frozen_string_literal: true

FactoryBot.define do
  factory :tag_vote do
    user
    votable_tag
  end
end
