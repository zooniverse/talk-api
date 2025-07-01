# frozen_string_literal: true

FactoryBot.define do
  factory :votable_tag do
    name { 'Vote For This Tag' }
    project_id { 1 }
    section { 'project-12' }
    taggable { nil }
  end
end
