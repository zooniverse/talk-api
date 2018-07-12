class Project < ActiveRecord::Base
  has_many :boards

  alias_attribute :title, :display_name
end
