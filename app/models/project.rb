class Project < ActiveRecord::Base
  has_many :boards
  has_and_belongs_to_many :collections
end
