class DiscussionSchema
  include JSON::SchemaBuilder
  root :discussions
  
  def create
    root do |root_object|
      additional_properties false
      string  :title,    required: true, min_length: 3, max_length: 140
      integer :board_id, required: true
      integer :user_id,  required: true
      sticky root_object
      
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
    root do |root_object|
      additional_properties false
      string :title, min_length: 3, max_length: 140
      integer :board_id
      boolean :locked
      sticky root_object
    end
  end
  
  def sticky(obj)
    obj.boolean :sticky, default: false
    obj.entity  :sticky_position do
      one_of number, null
    end
  end
end
