class SubjectSerializer
  include TalkSerializer
  attributes :id, :zooniverse_id, :metadata, :locations, :created_at, :updated_at, :project_id
  
  def locations
    MediumSerializer.as_json(model.locations.to_a) if model.locations
  rescue
    nil
  end
end
