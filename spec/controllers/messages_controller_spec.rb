require 'spec_helper'

RSpec.describe MessagesController, type: :controller do
  let(:resource){ Message }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller restricting',
    create: { status: 401, response: :error },
    destroy: { status: 401, response: :error },
    update: { status: 401, response: :error }
  
  context 'without an authorized user' do
    let(:user){ create :user }
    before(:each){ allow(subject).to receive(:current_user).and_return user }
    
    it_behaves_like 'a controller restricting',
      index: { status: 200, response: :empty },
      show: { status: 401, response: :error },
      create: { status: 401, response: :error },
      update: { status: 401, response: :error }
  end
  
  context 'with an authorized user' do
    let(:record){ create :message }
    before(:each){ allow(subject).to receive(:current_user).and_return record.user }
    
    it_behaves_like 'a controller rendering', :index, :show
    it_behaves_like 'a controller restricting',
      update: { status: 401, response: :error }
    
    it_behaves_like 'a controller creating' do
      let(:current_user){ record.user }
      let!(:conversation){ create :conversation_with_messages, user: current_user }
      let(:request_params) do
        {
          messages: {
            body: 'works',
            conversation_id: conversation.id
          }
        }
      end
    end
  end
end
