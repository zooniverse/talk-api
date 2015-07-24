class CommentSchema
  include JSON::SchemaBuilder
  include FocusSchema
  attr_accessor :policy
  
  root :comments
  
  def create
    root do |root_object|
      changes root_object, required: true
      id :user_id, required: true
      id :discussion_id, required: true
    end
  end
  
  def update
    root do |root_object|
      changes root_object
      id :discussion_id if policy.move?
    end
  end
  
  def changes(obj, required = { })
    obj.additional_properties false
    obj.string :category
    obj.string :body, **required
    focus obj
  end
end
