class ApplicationService
  include TalkService
  
  def self.inherited(base)
    base.model_class = base.name.sub(/Service$/, '').constantize
    base.schema_class = "#{ base.model_class.name }Schema".constantize
  end
end
