require 'restpack_serializer'

module RestPack::Serializer
  class SideLoadDataBuilder
    # Bug fix.  Prevent side loaded association from try to find non-existant records
    def side_load_belongs_to
      foreign_keys = @models.map { |model| model.send(@association.foreign_key) }.uniq.compact
      side_load = foreign_keys.any? ? @association.klass.find(foreign_keys) : []
      json_model_data = side_load.map { |model| @serializer.as_json(model) }
      { @association.plural_name.to_sym => json_model_data, meta: { } }
    end
  end
  
  def add_links(model, data)
    self.class.associations.each do |association|
      data[:links] ||= {}
      links_value = case
      when association.macro == :belongs_to && association.polymorphic?
        model.send association.name
      when association.macro == :belongs_to
        model.send(association.foreign_key).try(:to_s)
      when association.macro.to_s.match(/has_/)
        if model.send(association.name).loaded?
          model.send(association.name).collect { |associated| associated.id.to_s }
        else
          model.send(association.name).pluck(:id).map(&:to_s)
        end
      end
      unless links_value.blank?
        data[:links][association.name.to_sym] = links_value
      end
    end
    data
  end
end

# preload autoloaded serializers
Dir[Rails.root.join('app/serializers/**/*.rb')].sort.each do |path|
  name = path.match(/serializers\/(.+)\.rb$/)[1]
  name.classify.constantize unless path =~ /serializers\/concerns/
end
