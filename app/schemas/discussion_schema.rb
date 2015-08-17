class DiscussionSchema
  include JSON::SchemaBuilder
  include FocusSchema
  root :discussions
  
  def create
    root do |root_object|
      additional_properties false
      string :title, required: true, min_length: 3, max_length: 140
      id :board_id, required: true
      id :user_id, required: true
      boolean :subject_default
      sticky root_object
      comments root_object
    end
  end
  
  def owner_update
    root do |root_object|
      additional_properties false
      string :title, min_length: 3, max_length: 140
    end
  end
  
  def update
    root do |root_object|
      additional_properties false
      string :title, min_length: 3, max_length: 140
      id :board_id
      boolean :locked
      sticky root_object
    end
  end
  
  def sticky(obj)
    obj.boolean :sticky, default: false
    obj.entity :sticky_position do
      one_of number, null
    end
  end
  
  def comments(obj)
    obj.array :comments, required: true, min_items: 1 do
      items type: :object do |comment_object|
        id :user_id, required: true
        string :category
        string :body, required: true
        focus comment_object
      end
    end
  end
end
