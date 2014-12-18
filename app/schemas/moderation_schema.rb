class ModerationSchema
  include JSON::SchemaBuilder
  
  root :moderations
  
  def create
    root do |root_object|
      string  :section
      integer :target_id,   required: true
      string  :target_type, required: true
      reports root_object
    end
  end
  
  def update
    root do |root_object|
      reports root_object
      actions root_object
    end
  end
  
  protected
  
  def state(obj)
    obj.string :state do
      enum Moderation.states.keys
      default default_state
    end
  end
  
  def default_state
    key = Moderation.column_defaults['state']
    Moderation.states.invert[key]
  end
  
  def reports(obj)
    obj.array :reports, min_items: 1 do
      items type: :object do
        integer :user_id, required: true
        string  :message, required: true
      end
    end
  end
  
  def actions(obj)
    obj.array :actions, min_items: 1 do
      items type: :object do |item|
        integer :user_id, required: true
        string  :message, required: true
        state item
      end
    end
  end
end
