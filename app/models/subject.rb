class Subject < ApplicationRecord
  self.primary_key = :id
  include Focusable
  belongs_to :project
end
