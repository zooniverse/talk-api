class TagExportWorker
  include ::DataExportWorker
  
  def find_each(&block)
    ::Tag.where(section: data_request.section).find_each &block
  end
  
  def row_from(tag)
    tag.attributes.except 'updated_at'
  end
end
