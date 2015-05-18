class SubjectSerializer
  include TalkSerializer
  attributes :id, :zooniverse_id, :metadata, :locations, :created_at, :updated_at, :project_id
  can_include :mentions, :comments
  
  def custom_attributes
    super.merge locations: locations
  end
  
  def locations
    MediumSerializer.as_json(model.locations.to_a) if model.locations
  rescue
    nil
  end
end
