class Subject < ActiveRecord::Base
  self.table_name = 'subjects'
  
  include Focusable
  belongs_to :project
end
