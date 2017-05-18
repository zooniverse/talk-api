require 'spec_helper'

RSpec.describe MessageService, type: :service do
  it_behaves_like 'a service', Message do
    let(:conversation){ create :conversation_with_messages, user: current_user }

    let(:create_params) do
      {
        messages: {
          body: 'works',
          conversation_id: conversation.id
        }
      }
    end

    it_behaves_like 'a service creating', Message do
      let(:recipients){ conversation.users - [current_user] }



      it 'should set the user ip' do
        expect(service.build.user_ip).to eql '1.2.3.4'
      end

      context 'when the recipient has blocked the sender' do
        it 'should fail' do
          create :blocked_user, user: recipients.first, blocked_user: current_user
          expect{ service.build }.to raise_error Talk::BlockedUserError
        end
      end

      context 'when the sender has blocked a recipient' do
        it 'should fail' do
          create :blocked_user, user: current_user, blocked_user: recipients.first
          expect{ service.build }.to raise_error Talk::UserBlockedError
        end
      end
    end

    context 'creating the message' do
      before(:each){ service.create }
      subject{ service.resource }
      its(:user){ is_expected.to eql current_user }
      it 'should change the conversations updated_at timestamp' do
        expect { service.build }.to change { conversation.updated_at }
      end
    end
  end
end
