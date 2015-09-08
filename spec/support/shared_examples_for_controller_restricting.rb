require 'spec_helper'

RSpec.shared_examples_for 'a restricted action' do
  it_behaves_like 'a controller action' do
    let(:resource_name){ resource.name.tableize.to_sym }
    
    it 'should respond appropriately' do
      send_request
      case expected_response
      when :error
        expect(response.json).to have_key :error
      when :empty
        expect(response.json[resource_name]).to be_empty
      end
    end
  end
end

RSpec.shared_examples_for 'a controller restricting' do |actions = { }|
  let(:record){ create resource }
  
  if actions[:index]
    describe '#index' do
      it_behaves_like 'a restricted action' do
        let(:verb){ :get }
        let(:action){ :index }
        let(:params){ { } }
        let(:authorizable){ resource unless actions[action][:status] == 405 }
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
        let(:authorizable){ resource.where(id: record.id) unless actions[action][:status] == 405 }
        let(:status){ actions[action][:status] }
        let(:expected_response){ actions[action][:response] }
      end
    end
  end
  
  if actions[:create]
    describe '#create' do
      it_behaves_like 'a restricted action' do
        let(:verb){ :post }
        let(:action){ :create }
        let(:params){ { } }
        let(:authorizable){ }
        let(:status){ actions[action][:status] }
        let(:expected_response){ actions[action][:response] }
      end
    end
  end
  
  if actions[:update]
    describe '#update' do
      it_behaves_like 'a restricted action' do
        let(:record){ create resource }
        let(:verb){ :put }
        let(:action){ :update }
        let(:params){ { id: record.id } }
        let(:authorizable){ }
        let(:status){ actions[action][:status] }
        let(:expected_response){ actions[action][:response] }
      end
    end
  end
  
  if actions[:destroy]
    describe '#destroy' do
      it_behaves_like 'a restricted action' do
        let(:verb){ :delete }
        let(:action){ :destroy }
        let(:params){ { id: record.id } }
        let(:authorizable){ record unless actions[action][:status] == 405 }
        let(:status){ actions[action][:status] }
        let(:expected_response){ actions[action][:response] }
      end
    end
  end
end
