require 'spec_helper'

RSpec.shared_examples_for 'a controller action' do
  let(:send_request){ send verb, action, params }
  
  it 'should authorize the action' do
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
  end
end
