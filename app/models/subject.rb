class Subject < ActiveRecord::Base
  include Focusable
  belongs_to :project
  has_many :locations, ->{ where(type: 'subject_location') }, class_name: 'Medium', as: :linked
  default_scope{ eager_load(:locations) }
end
