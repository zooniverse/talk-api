class Project < ApplicationRecord
  self.primary_key = :id
  has_many :boards

  alias_attribute :title, :display_name
end
