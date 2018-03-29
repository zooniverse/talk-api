class CollectionSerializer
  include TalkSerializer
  attributes :id, :name, :project_ids, :created_at, :updated_at, :display_name, :private
end
