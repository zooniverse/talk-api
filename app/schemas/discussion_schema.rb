class DiscussionSchema
  include JSON::SchemaBuilder
  root :discussions
  
  def create
    root do |root_object|
      additional_properties false
      string  :title,          required: true, min_length: 3, max_length: 140
      entity  :board_id,       required: true  do
        one_of string, integer
      end
      entity :user_id,         required: true do
        one_of string, integer
      end
      boolean :subject_default
      sticky root_object
      
      array :comments, required: true, min_items: 1 do
        items type: :object do
          entity :user_id, required: true do
            one_of string, integer
          end
          
          string  :category
          string  :body,    required: true
          entity :focus_id do
            one_of string, integer, null
          end
        end
      end
    end
  end
  
  def update
    root do |root_object|
      additional_properties false
      string :title, min_length: 3, max_length: 140
      entity :board_id do
        one_of string, integer
      end
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
