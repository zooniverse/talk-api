require 'spec_helper'

RSpec.shared_examples_for 'a controller' do |resource|
  context 'with reflection helpers' do
    it 'should find the model class name' do
      expect(subject.model_class_name).to eql resource.name
    end
    
    it 'should find the model class' do
      expect(subject.model_class).to eql resource
    end
    
    it 'should find the serializer' do
      expect(subject.serializer_class).to eql "#{ resource.name }Serializer".constantize
    end
  end
end
