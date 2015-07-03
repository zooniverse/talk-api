class CommentSchema
  include JSON::SchemaBuilder
  attr_accessor :policy

  root :comments

  def create
    root do
      additional_properties false
      entity  :user_id,       required: true do
        one_of string, integer
      end
      string  :category
      string  :body,          required: true
      entity  :focus_id do
        one_of string, integer
      end
      entity  :discussion_id, required: true do
        one_of string, integer
      end
    end
  end

  def update
    root do
      additional_properties false
      string  :category
      string  :body
      if policy.move?
        entity :discussion_id do
          one_of string, integer
        end
      end
      entity :focus_id do
        one_of string, integer
      end
    end
  end
end
