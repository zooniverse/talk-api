# frozen_string_literal: true

class VotableTagSchema
  include JSON::SchemaBuilder
  attr_accessor :policy

  root :votable_tags

  def create
    root do
      additional_properties false
      string :name, required: true
      string :section, required: true
      id :taggable_id, null: true
      entity :taggable_type, null: true do
        enum %w[Subject]
      end
    end
  end
end
