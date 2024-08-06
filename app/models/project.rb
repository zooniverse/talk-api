class Project < ApplicationRecord
  has_many :boards

  alias_attribute :title, :display_name
end
