class MediumSerializer
  include TalkSerializer
  attributes :id, :href, :content_type, :media_type, :external_link
  
  def media_type
    model.type
  end
  
  def links
    {
      linked: model.linked_id.to_s,
      linked_type: 'Subject'
    } if model.linked_id
  end
end
