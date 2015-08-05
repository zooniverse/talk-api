class Subject < ActiveRecord::Base
  include Focusable
  belongs_to :project
end
