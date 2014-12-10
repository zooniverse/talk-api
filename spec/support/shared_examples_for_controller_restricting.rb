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
