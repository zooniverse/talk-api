class SubjectSerializer
  include TalkSerializer
  attributes :id, :zooniverse_id, :metadata, :locations, :created_at, :updated_at, :project_id
  can_include :mentions, :comments
end
