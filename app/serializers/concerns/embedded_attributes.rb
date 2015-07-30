module EmbeddedAttributes
  extend ActiveSupport::Concern
  
  def discussion_attributes
    %w(comments_count subject_default title updated_at users_count)
  end
  
  def board_attributes
    %w(comments_count description discussions_count id parent_id subject_default title users_count)
  end
  
  def project_attributes
    %w(slug)
  end
  
  def attributes_from(relation)
    { }.tap do |attrs|
      record_attributes = model.send(relation).attributes rescue { }
      send("#{ relation }_attributes").each do |attr|
        value = record_attributes[attr]
        value = value.to_s if attr =~ /(_id)|(^id$)$/
        attrs[:"#{ relation }_#{ attr }"] = value
      end
    end
  end
end
