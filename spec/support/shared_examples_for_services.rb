require 'spec_helper'

RSpec.shared_examples_for 'a service' do |resource|
  subject{ described_class }
  let(:resource_schema){ "#{ resource.name }Schema".constantize }
  let(:params){ { resource.table_name => { } } }
  let(:action){ :create }
  let(:current_user){ create :user }
  let(:service){ described_class.new **options }
  let(:options) do
    {
      params: ActionController::Parameters.new(params),
      action: action,
      current_user: current_user
    }
  end
  
  its(:model_class){ is_expected.to eql resource }
  its(:schema_class){ is_expected.to eql resource_schema }
  
  describe '#initialize' do
    subject{ service }
    its(:params){ is_expected.to eql options[:params] }
    its(:action){ is_expected.to eql action }
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
    let(:params){ { resource.table_name => { foo: 1 } } }
    subject{ service.rooted_params }
    it{ is_expected.to include resource.table_name => { 'foo' => 1 } }
    
    it 'should permit the params' do
      expect(service).to receive(:permitted_params).and_call_original
      subject
    end
  end
  
  describe '#unrooted_params' do
    let(:params){ { resource.table_name => { foo: 1 } } }
    subject{ service.unrooted_params }
    it{ is_expected.to include 'foo' => 1 }
    
    it 'should permit the params' do
      expect(service).to receive(:permitted_params).and_call_original
      subject
    end
  end
  
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
  
  describe '#policy' do
    it 'should use the Pundit policy' do
      service.build
      expect(Pundit).to receive(:policy!)
        .with service.current_user, service.resource
      service.policy
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
        .to receive(action).and_call_original
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
  
  describe '#authorize' do
    it 'should build the resource' do
      expect(service).to receive(:build).once.and_call_original
      2.times{ service.authorize }
    end
    
    it 'should authorize the action' do
      policy = double
      expect(policy).to receive("#{ action }?").and_return true
      expect(service).to receive(:policy).and_return policy
      service.authorize
    end
    
    it 'should raise an error if unauthorized' do
      expect(service).to receive(:policy)
        .and_return double "#{ action }?" => false
      expect{
        service.authorize
      }.to raise_error Pundit::NotAuthorizedError
    end
    
    it 'should be authorized' do
      expect(service).to receive(:policy)
        .and_return double "#{ action }?" => true
      expect{
        service.authorize
      }.to change {
        service.authorized?
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
