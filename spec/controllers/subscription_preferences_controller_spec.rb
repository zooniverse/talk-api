require 'spec_helper'

RSpec.describe SubscriptionPreferencesController, type: :controller do
  let(:resource){ SubscriptionPreference }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller restricting',
    index: { status: 401, response: :error },
    show: { status: 401, response: :error },
    create: { status: 405, response: :error },
    destroy: { status: 405, response: :error },
    update: { status: 401, response: :error }

  context 'without an authorized user' do
    let(:user){ create :user }
    before(:each){ allow(subject).to receive(:current_user).and_return user }

    it_behaves_like 'a controller rendering', :index
    it_behaves_like 'a controller restricting',
      show: { status: 401, response: :error },
      create: { status: 405, response: :error },
      destroy: { status: 405, response: :error },
      update: { status: 401, response: :error }
  end

  context 'with an authorized user' do
    before(:each){ allow(subject).to receive(:current_user).and_return record.user }

    it_behaves_like 'a controller rendering', :index, :show
    it_behaves_like 'a controller restricting',
      create: { status: 405, response: :error },
      destroy: { status: 405, response: :error }

    it_behaves_like 'a controller updating' do
      let(:current_user){ record.user }
      let(:request_params) do
        {
          id: record.id.to_s,
          subscription_preferences: {
            enabled: true,
            email_digest: 'weekly'
          }
        }
      end
    end
  end
end
