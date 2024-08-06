class Subject < ApplicationRecord
  include Focusable
  belongs_to :project
end
