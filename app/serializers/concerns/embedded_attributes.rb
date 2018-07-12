module EmbeddedAttributes
  extend ActiveSupport::Concern

  included do
    class_attribute :_embedded_attributes
    self._embedded_attributes = []
  end

  module ClassMethods
    def embed_attributes_from(*list)
      self._embedded_attributes += list.map(&:to_sym)
      self._embedded_attributes.uniq!
    end
  end

  def discussion_attributes
    %w(comments_count subject_default title updated_at users_count focus_id focus_type locked)
  end

  def board_attributes
    %w(comments_count description discussions_count id parent_id subject_default title users_count permissions)
  end

  def project_attributes
    %w(slug title)
  end

  def custom_attributes
    super.tap do |custom_attrs|
      self._embedded_attributes.each do |relation|
        custom_attrs.merge! attributes_from relation
      end
    end
  end

  def attributes_from(relation)
    { }.tap do |attrs|
      record_attributes = relation_record_attributes_and_aliases(
        model.send(relation)
      )

      send("#{ relation }_attributes").each do |attr|
        value = record_attributes[attr]
        value = value.to_s if attr =~ /(_id)|(^id$)$/
        attrs[:"#{ relation }_#{ attr }"] = value
      end
    end
  end

  def relation_record_attributes_and_aliases(relation_record)
    if relation_record
      aliased_attrs = {}
      relation_record.attribute_aliases.each do |key, aliased_attr|
        aliased_attrs[key] = relation_record.send(aliased_attr)
      end
      relation_record.attributes.merge(aliased_attrs)
    else
      {}
    end
  end
end
