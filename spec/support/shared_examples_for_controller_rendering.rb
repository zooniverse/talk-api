require 'spec_helper'

RSpec.shared_examples_for 'a controller rendering' do |*actions|
  let(:record){ create resource.name.underscore.to_sym }
  
  if :index.in? actions
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
  end
  
  if :show.in? actions
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
end
