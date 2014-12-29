require 'spec_helper'

RSpec.shared_examples_for 'a controller' do
  context 'with reflection helpers' do
    it 'should find the model class' do
      expect(subject.model_class).to eql resource
    end
    
    it 'should find the serializer' do
      expect(subject.serializer_class).to eql "#{ resource.name }Serializer".constantize
    end
    
    it 'should find the schema class' do
      klass_name = "#{ resource.name }Schema"
      if Kernel.const_defined?(klass_name)
        expect(subject.schema_class).to eql klass_name.constantize
      end
    end
    
    it 'should find the service class' do
      klass_name = "#{ resource.name }Service"
      klass = Kernel.const_defined?(klass_name) ? klass_name.constantize : ApplicationService
      expect(subject.service_class).to eql klass
    end
  end
end
