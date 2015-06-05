class Role < ActiveRecord::Base
  belongs_to :user, required: true
  
  validates :user_id, uniqueness: {
    scope: [:name, :section],
    message: 'Role already exists for this user and section'
  }
end
