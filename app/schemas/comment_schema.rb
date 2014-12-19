class CommentSchema
  include JSON::SchemaBuilder
  attr_accessor :policy
  
  root :comments
  
  def create
    root do
      additional_properties false
      integer :user_id,       required: true
      string  :category
      string  :body,          required: true
      integer :focus_id
      integer :discussion_id, required: true
    end
  end
  
  def update
    root do
      additional_properties false
      string  :category
      string  :body,          required: true
      integer :discussion_id, required: true if policy.move?
      integer :focus_id
    end
  end
end
