class Role < ActiveRecord::Base
  include BooleanCoercion
  belongs_to :user, required: true
  
  validates :is_shown, inclusion: {
    in: [true, false],
    message: 'must be true or false'
  }
  
  validates :user_id, uniqueness: {
    scope: [:name, :section],
    message: 'Role already exists for this user and section'
  }
end
