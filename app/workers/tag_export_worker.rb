class TagExportWorker
  include ::DataExportWorker
  
  def find_each(&block)
    section_tags.find_each batch_size: batch_size, &block
  end
  
  def section_tags
    ::Tag.where(section: data_request.section)
  end
  
  def row_count
    section_tags.count
  end
  
  def row_from(tag)
    tag.attributes.except 'updated_at'
  end
end
