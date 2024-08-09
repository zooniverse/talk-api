require 'spec_helper'

RSpec.describe UnsubscribeController, type: :controller do
  describe '#index' do
    let(:user){ create :user }
    let(:valid_token){ create(:unsubscribe_token, user: user).token }

    context 'with a valid token' do
      it 'should render' do
        get :index, params: { token: valid_token }
        expect(response).to be_ok
      end

      it 'should log the event' do
        expect(EventLog).to receive(:create).with label: 'unsubscribe', user_id: user.id, payload: { ip: String }
        get :index, params: { token: valid_token }
      end

      it 'should unsubscribe the user' do
        get :index, params: { token: valid_token }
        digests = user.subscription_preferences.map &:email_digest
        expect(digests).to all eql 'never'
      end
    end

    context 'without a valid token' do
      it 'should render' do
        get :index, params: { token: 'nope' }
        expect(response).to be_ok
      end

      it 'should log the event' do
        expect(EventLog).to receive(:create).with label: 'unsubscribe', user_id: nil, payload: { ip: String }
        get :index, params: { token: 'nope' }
      end
    end
  end
end
