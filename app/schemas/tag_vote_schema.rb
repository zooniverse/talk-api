# frozen_string_literal: true

class TagVoteSchema
  include JSON::SchemaBuilder

  root :tag_votes

  def create
    root do
      additional_properties false
      id :user_id, required: true
      id :votable_tag_id, required: true
    end
  end
end
