require 'spec_helper'

RSpec.shared_examples_for 'a restricted action' do
  let(:resource_name){ resource.name.tableize.to_sym }
  
  def send_request
    send verb, action, params
  end
  
  it 'should not authorize the action' do
    expect(subject).to receive(:authorize).with(authorizable).and_call_original
    send_request
  end
  
  context 'with a response' do
    before(:each){ send_request }
    
    it 'should set the correct status' do
      expect(response.status).to eql status
    end
    
    it 'should be json' do
      expect(response.content_type).to eql 'application/json'
    end
    
    it 'should be an object' do
      expect(response.json).to be_a Hash
    end
    
    it 'should respond' do
      case expected_response
      when :error
        expect(response.json).to have_key :error
      when :empty
        expect(response.json[resource_name]).to be_empty
      end
    end
  end
end

RSpec.shared_examples_for 'a controller restricting' do |resource, actions = { }|
  let(:resource){ resource }
  let(:record){ create resource.name.underscore.to_sym }
  
  if actions[:index]
    describe '#index' do
      it_behaves_like 'a restricted action' do
        let(:verb){ :get }
        let(:action){ :index }
        let(:params){ { } }
        let(:authorizable){ resource }
        let(:status){ actions[action][:status] }
        let(:expected_response){ actions[action][:response] }
      end
    end
  end
  
  if actions[:show]
    describe '#show' do
      it_behaves_like 'a restricted action' do
        let(:verb){ :get }
        let(:action){ :show }
        let(:params){ { id: record.id } }
        let(:authorizable){ resource.where(id: record.id) }
        let(:status){ actions[action][:status] }
        let(:expected_response){ actions[action][:response] }
      end
    end
  end
end
