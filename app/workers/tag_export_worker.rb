class TagExportWorker
  include ::DataExportWorker
  self.name = 'tags'
  
  def find_each(&block)
    ::Tag.where(section: section).find_each &block
  end
  
  def row_from(tag)
    tag.attributes.except :updated_at
  end
end
