require 'spec_helper'

RSpec.shared_examples_for 'a controller rendering' do |resource|
  let(:record){ create resource.name.underscore.to_sym }
  
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
  
  describe '#index' do
    it 'should authorize the action' do
      expect(subject).to receive(:authorize).with(resource).and_call_original
      get :index
    end
    
    it 'should use the policy scope' do
      expect(subject).to receive(:policy_scope).with(resource).and_call_original
      get :index
    end
    
    it 'should paginate the serializer' do
      expect(subject.serializer_class).to receive(:page).and_call_original
      get :index
    end
    
    it 'should respond with json' do
      get :index
      expect(response.content_type).to eql 'application/json'
      expect(response.json).to be_a Hash
    end
  end
  
  describe '#show' do
    it 'should authorize the user' do
      expect(subject).to receive(:authorize).with(resource.where(id: record.id)).and_call_original
      get :show, id: record.id
    end
    
    it 'should serialize the resource' do
      expect(subject.serializer_class).to receive(:resource).and_call_original
      get :show, id: record.id
    end
    
    it 'should respond with json' do
      get :show, id: record.id
      expect(response.content_type).to eql 'application/json'
      expect(response.json).to be_a Hash
    end
  end
end
