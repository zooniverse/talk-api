class ConversationSchema
  include JSON::SchemaBuilder

  root :conversations

  def create
    root do
      additional_properties false
      string  :title,   required: true
      entity  :user_id, required: true  do
        one_of string, integer
      end
      string  :body,    required: true

      array :recipient_ids, required: true, unique_items: true, min_items: 1 do
        items do
          entity :string_or_positive_integer do
            one_of string, positive_int
          end
        end
      end
    end
  end

  def positive_int
    integer do
      minimum 0
      exclusive_minimum true
    end
  end
end
