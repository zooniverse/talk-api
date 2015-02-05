class DiscussionSchema
  include JSON::SchemaBuilder
  root :discussions
  
  def create
    root do
      additional_properties false
      string  :title,    required: true, min_length: 3, max_length: 140
      integer :board_id, required: true
      integer :user_id,  required: true
      
      array :comments, required: true, min_items: 1 do
        items type: :object do
          integer :user_id, required: true
          string  :category
          string  :body,    required: true
          integer :focus_id
        end
      end
    end
  end
  
  def update
    root do
      additional_properties false
      string :title, min_length: 3, max_length: 140
      integer :board_id
      boolean :locked
      boolean :sticky
      entity :sticky_position do
        one_of integer, null
      end
    end
  end
end
