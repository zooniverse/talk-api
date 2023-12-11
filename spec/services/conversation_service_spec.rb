require 'spec_helper'

RSpec.describe ConversationService, type: :service do
  it_behaves_like 'a service', Conversation do
    let(:recipients){ create_list :user, 2 }
    let(:recipient_ids){ recipients.collect &:id }
    let(:create_params) do
      {
        conversations: {
          title: 'works',
          body: 'a message',
          recipient_ids: recipients.collect(&:id)
        }
      }
    end

    context 'creating the conversation' do
      before(:each){ service.create }
      subject{ service.resource }

      its(:title){ is_expected.to eql 'works' }

      context 'with a sender conversation' do
        subject do
          service.resource.user_conversations.where(user_id: current_user.id).first
        end

        its(:conversation){ is_expected.to eql service.resource }
        its(:user){ is_expected.to eql current_user }
        its(:is_unread){ is_expected.to be false }
      end

      context 'with recipient_conversations' do
        subject do
          service.resource.user_conversations.where user_id: recipient_ids
        end

        it 'should set the conversations' do
          expect(subject.collect(&:conversation)).to eql [service.resource] * 2
        end

        it 'should set the users' do
          expect(subject.collect(&:user)).to match_array recipients
        end

        it 'should set the unread status' do
          expect(subject.collect(&:is_unread)).to eql [true, true]
        end
      end

      context 'with a message' do
        subject{ service.resource.messages.first }
        its(:body){ is_expected.to eql 'a message' }
        its(:conversation){ is_expected.to eql service.resource }
        its(:user){ is_expected.to eql current_user }
        its(:user_ip){ is_expected.to eql '1.2.3.4' }
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

      context 'when the sender is unconfirmed' do
        it 'should fail' do
          current_user.confirmed_at = nil
          expect{ service.build }.to raise_error Talk::UserUnconfirmedError
        end
      end
    end
  end
end
