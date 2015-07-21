class CommentSchema
  include JSON::SchemaBuilder
  attr_accessor :policy
  
  root :comments
  
  def create
    root do |root_object|
      additional_properties false
      entity  :user_id,       required: true do
        one_of string, integer
      end
      string  :category
      string  :body,          required: true
      focus root_object
      entity  :discussion_id, required: true do
        one_of string, integer
      end
    end
  end
  
  def update
    root do |root_object|
      additional_properties false
      string  :category
      string  :body
      if policy.move?
        entity :discussion_id do
          one_of string, integer
        end
      end
      focus root_object
    end
  end
  
  def focus(obj)
    obj.entity :focus_id do
      one_of string, integer, null
    end
    
    obj.entity :focus_type do
      enum %w(Subject Collection)
    end
  end
end
