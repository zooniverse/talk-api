class DiscussionSchema
  include JSON::SchemaBuilder
  attr_accessor :policy
  root :discussions
  
  def create
    schema
  end
  
  def update
    schema
  end
  
  def schema
    root do
      string :title, required: true, min_length: 3, max_length: 140
      
      if privileged?
        integer :board_id, required: true
        boolean :locked
        boolean :sticky
      end
    end
  end
  
  def privileged?
    policy.moderator? || policy.admin?
  end
end
