class CollectionSerializer
  include TalkSerializer
  attributes :id, :name, :project_id, :created_at, :updated_at, :display_name, :private
end
