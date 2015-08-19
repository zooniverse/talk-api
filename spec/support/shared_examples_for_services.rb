require 'spec_helper'

RSpec.shared_examples_for 'a service' do |resource, sets_user: true|
  subject{ described_class }
  let(:resource_schema){ "#{ resource.name }Schema".constantize }
  
  let(:create_params){ { resource.table_name => { } } }
  let(:update_params){ { resource.table_name => { } } }
  let(:params){ create_params }
  let(:current_user){ create :user }
  
  let(:update_options) do
    {
      params: ActionController::Parameters.new(update_params),
      action: :update,
      current_user: current_user,
      user_ip: '1.2.3.4'
    }
  end
  
  let(:create_options) do
    {
      params: ActionController::Parameters.new(create_params),
      action: :create,
      current_user: current_user,
      user_ip: '1.2.3.4'
    }
  end
  
  let(:options){ create_options }
  let(:service){ described_class.new **options }
  
  its(:model_class){ is_expected.to eql resource }
  its(:schema_class){ is_expected.to eql resource_schema }
  
  describe '#initialize' do
    subject{ service }
    its(:params){ is_expected.to eql options[:params] }
    its(:action){ is_expected.to eql options[:action] }
    its(:current_user){ is_expected.to eql current_user }
    its(:model_class){ is_expected.to eql resource }
    its(:schema_class){ is_expected.to eql resource_schema }
  end
  
  describe '#permitted_params' do
    it 'should permit the params' do
      expect(service.params).to receive(:permitted?).and_return false
      expect(service.params).to receive :permit!
      service.permitted_params
    end
    
    it 'should not permit the params multiple times' do
      expect(service.params).to receive(:permitted?).and_return true
      expect(service.params).to_not receive :permit!
      service.permitted_params
    end
  end
  
  describe '#rooted_params' do
    let(:create_params){ { resource.table_name => { foo: 1 } } }
    subject{ service.rooted_params }
    it{ is_expected.to include resource.table_name => { 'foo' => 1 } }
    
    it 'should permit the params' do
      expect(service).to receive(:permitted_params).and_call_original
      subject
    end
  end
  
  describe '#unrooted_params' do
    let(:create_params){ { resource.table_name => { foo: 1 } } }
    subject{ service.unrooted_params }
    it{ is_expected.to include 'foo' => 1 }
    
    it 'should permit the params' do
      expect(service).to receive(:permitted_params).and_call_original
      subject
    end
  end
  
  if sets_user
    describe '#set_user' do
      context 'without a user' do
        let(:current_user){ nil }
        it 'should raise an error' do
          expect{ service.set_user }.to raise_error Pundit::NotAuthorizedError
        end
      end
      
      context 'without valid params' do
        it 'should raise an error' do
          expect{
            service.set_user do
              unrooted_params[:does][:not][:exist] = 123
            end
          }.to raise_error TalkService::ParameterError
        end
      end
      
      it 'should set the user id' do
        expect{
          service.set_user
        }.to change{
          service.unrooted_params[:user_id]
        }.from(nil).to current_user.id
      end
      
      it 'should accept a block' do
        expect{
          service.set_user{ unrooted_params[:foo] = 123 }
        }.to change{
          service.unrooted_params[:foo]
        }.from(nil).to 123
      end
    end
  end
  
  describe '#policy' do
    it 'should use the Pundit policy' do
      service.build
      expect(Pundit).to receive(:policy!)
        .with service.current_user, service.resource
      service.policy
    end
  end
  
  describe '#authorize' do
    it 'should authorize the action' do
      policy = double
      expect(policy).to receive("#{ options[:action] }?").and_return true
      expect(service).to receive(:policy).and_return policy
      service.authorize
    end
    
    it 'should raise an error if unauthorized' do
      expect(service).to receive(:policy)
        .and_return double "#{ options[:action] }?" => false
      expect{
        service.authorize
      }.to raise_error Pundit::NotAuthorizedError
    end
    
    it 'should be authorized' do
      expect(service).to receive(:policy)
        .and_return double "#{ options[:action] }?" => true
      expect{
        service.authorize
      }.to change {
        service.authorized?
      }.from(false).to true
    end
  end
end

RSpec.shared_examples_for 'a service creating' do |resource|
  describe '#authorize' do
    it 'should build the resource' do
      expect(service).to receive(:build).once.and_call_original
      2.times{ service.authorize }
    end
  end
  
  describe '#validate' do
    it 'should build the schema' do
      expect(service.schema_class).to receive(:new)
        .with(policy: an_instance_of(service.policy.class))
        .and_call_original
      service.validate
    end
    
    it 'should use the schema action' do
      expect_any_instance_of(service.schema_class)
        .to receive(options[:action]).and_call_original
      service.validate
    end
    
    it 'should validate the schema' do
      schema = double create: double
      expect(service.schema_class).to receive(:new).and_return schema
      expect(schema.create).to receive(:validate!)
        .with(service.rooted_params)
      service.validate
    end
    
    it 'should be validated' do
      expect {
        service.validate
      }.to change {
        service.validated?
      }.from(false).to true
    end
  end
  
  describe '#create' do
    it 'should build the resource' do
      expect(service).to receive(:build).once.and_call_original
      2.times{ service.create }
    end
    
    it 'should authorize the action' do
      expect(service).to receive(:authorize).once.and_call_original
      2.times{ service.create }
    end
    
    it 'should validate the params' do
      expect(service).to receive(:validate).once.and_call_original
      2.times{ service.create }
    end
    
    it 'should save the resource' do
      service.build
      expect(service.resource).to receive :save!
      service.create
    end
  end
end

RSpec.shared_examples_for 'a service updating' do |resource|
  let(:creation_service){ described_class.new **create_options }
  let(:record){ create resource }
  let(:params){ update_params }
  let(:options){ update_options }
  
  describe '#validate' do
    before(:each){ service.find_resource }
    
    it 'should use the schema action' do
      expect_any_instance_of(service.schema_class)
        .to receive(:update).and_return double :validate! => true
      service.validate
    end
    
    it 'should validate the schema' do
      schema = double update: double
      expect(service.schema_class).to receive(:new).and_return schema
      expect(schema.update).to receive(:validate!)
        .with(service.rooted_params)
      service.validate
    end
    
    it 'should be validated' do
      expect_any_instance_of(service.schema_class)
        .to receive(:update).and_return double :validate! => true
      
      expect {
        service.validate
      }.to change {
        service.validated?
      }.from(false).to true
    end
  end
  
  describe '#find_resource' do
    it 'should find the resource' do
      expect(service.model_class).to receive(:find).with record.id
      service.find_resource
    end
  end
  
  describe '#update_resource' do
    it 'should assign the attributes' do
      service.find_resource
      expect(service.resource).to receive(:assign_attributes).with a_kind_of Hash
      service.update_resource
    end
  end
  
  describe '#update' do
    it 'should find the resource' do
      expect(service.model_class).to receive(:find)
        .with(record.id).once.and_call_original
      2.times{ service.update }
    end
    
    it 'should authorize the action' do
      expect(service).to receive(:authorize).once.and_call_original
      2.times{ service.update }
    end
    
    it 'should validate the params' do
      expect(service).to receive(:validate).once.and_call_original
      2.times{ service.update }
    end
    
    it 'should update the record attributes' do
      expect(service).to receive(:update_resource).once.and_call_original
      service.update
    end
    
    it 'should update the record' do
      service.find_resource
      expect(service.resource).to receive :save!
      service.update
    end
  end
end
