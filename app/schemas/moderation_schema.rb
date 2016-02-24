class ModerationSchema
  include JSON::SchemaBuilder

  root :moderations

  def create
    root do |root_object|
      additional_properties false
      string :section, required: true
      id :target_id, required: true
      string :target_type, required: true
      reports root_object
    end
  end

  def update
    root do |root_object|
      additional_properties false
      reports root_object
      actions root_object
    end
  end

  protected

  def action(obj)
    obj.string :action do
      enum [:destroy, :ignore, :watch]
    end
  end

  def reports(obj)
    obj.array :reports, min_items: 1 do
      items type: :object do
        id :user_id, required: true
        string :message, required: true
      end
    end
  end

  def actions(obj)
    obj.array :actions, min_items: 1 do
      items type: :object do |item|
        id :user_id, required: true
        action item
        string :message, required: true
      end
    end
  end
end
