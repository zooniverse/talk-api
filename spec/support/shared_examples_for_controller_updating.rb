require 'spec_helper'

RSpec.shared_examples_for 'a controller updating' do
  let(:current_user){ create :user }
  let(:request_params){ raise 'No request params set' }
  let(:schema_method){ :update }
  let(:record){ create resource.name.tableize.singularize.to_sym }

  before :each do
    allow(subject).to receive(:current_user).and_return current_user
    request.headers['CONTENT_TYPE'] = 'application/json'
  end

  describe '#update' do
    let(:send_request){ put :update, params: request_params.merge(format: :json) }

    it 'should authorize the action' do
      expect_any_instance_of(subject.service_class).to receive :authorize
      send_request
    end

    it 'should use schema#update' do
      expect_any_instance_of(subject.schema_class).to receive(schema_method).and_call_original
      send_request
    end

    it 'should validate the params' do
      schema = double
      expect(subject.schema_class).to receive_message_chain(:new, schema_method).and_return schema
      expect(schema).to receive :validate!
      send_request
    end

    it 'should update the record' do
      expect{ send_request }.to change{ record.reload.updated_at }
    end

    it 'should serialize the resource' do
      expect(subject.serializer_class).to receive(:resource).and_call_original
      send_request
    end

    context 'with a response' do
      before(:each){ send_request }

      it 'should set the correct status' do
        expect(response.status).to eql 200
      end

      it 'should be json' do
        expect(response.content_type).to eql 'application/json'
      end

      it 'should be an object' do
        expect(response.json).to be_a Hash
      end
    end

    if ENV['EVIL_MODE']
      context 'with invalid parameters' do
        include_context 'mangled params'

        it 'should not blow up' do
          expect{
            post :update, mangle(request_params).merge(id: record.id, format: :json)
          }.to_not raise_error
        end
      end
    end
  end
end
