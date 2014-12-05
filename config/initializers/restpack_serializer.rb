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
end

# preload autoloaded serializers
Dir[Rails.root.join('app/serializers/**/*.rb')].sort.each do |path|
  name = path.match(/serializers\/(.+)\.rb$/)[1]
  name.classify.constantize unless path =~ /serializers\/concerns/
end
