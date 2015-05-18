class Medium < ActiveRecord::Base
  belongs_to :linked, polymorphic: true
  self.inheritance_column = nil
end
