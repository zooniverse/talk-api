require 'spec_helper'

RSpec.describe MessagesController, type: :controller do
  let(:resource){ Message }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller restricting',
    create: { status: 401, response: :error },
    destroy: { status: 405, response: :error },
    update: { status: 405, response: :error }

  context 'without an authorized user' do
    let(:user){ create :user }
    before(:each){ allow(subject).to receive(:current_user).and_return user }

    it_behaves_like 'a controller restricting',
      index: { status: 200, response: :empty },
      show: { status: 401, response: :error },
      create: { status: 401, response: :error },
      update: { status: 405, response: :error },
      destroy: { status: 405, response: :error }
  end

  context 'with an authorized user' do
    let(:record){ create :message }
    before(:each){ allow(subject).to receive(:current_user).and_return record.user }

    it_behaves_like 'a controller rendering', :index, :show
    it_behaves_like 'a controller restricting',
      update: { status: 405, response: :error },
      destroy: { status: 405, response: :error }

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

      it 'should set the user ip' do
        post :create, params: request_params.merge(format: :json)
        id = response.json['messages'].first['id']
        message = Message.find id
        expect(message.user_ip).to eql request.remote_ip
      end
    end

    describe '#show' do
      context 'getting multiple messages' do
        context 'when the user is not a participant to at least one of the messages' do
          let(:other_user){ create :user }
          let(:other_conversation){ create :conversation_with_messages, user: other_user }

          it 'returns 401 if the user is not a participant to at least one of the messages' do
            get :show, params: { id: [record.id, other_conversation.messages.first.id] }
            expect(response.status).to eq 401
          end
  
          it 'returns 401 if the unauthorized message is the first in the list' do
            get :show, params: { id: [other_conversation.messages.first.id, record.id] }
            expect(response.status).to eq 401
          end
        end

        it 'returns 200 if the user is a participant to all of the messages' do
          other_message = create :message, conversation: record.conversation, user: record.user
          get :show, params: { id: [record.id, other_message.id] }
          expect(response.status).to eq 200
        end
      end
    end
  end
end
