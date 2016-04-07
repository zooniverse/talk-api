require 'spec_helper'

RSpec.describe SubscriptionsController, type: :controller do
  let(:resource){ Subscription }
  let(:discussion){ create :discussion }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller restricting',
    index: { status: 401, response: :error },
    show: { status: 401, response: :error },
    create: { status: 401, response: :error },
    destroy: { status: 405, response: :error },
    update: { status: 401, response: :error }

  context 'with a user' do
    let(:user){ create :user }
    before(:each){ allow(subject).to receive(:current_user).and_return user }

    it_behaves_like 'a controller rendering', :index
    it_behaves_like 'a controller restricting',
      show: { status: 401, response: :error },
      destroy: { status: 405, response: :error },
      update: { status: 401, response: :error }

    it_behaves_like 'a controller creating' do
      let(:current_user){ user }
      let(:request_params) do
        {
          subscriptions: {
            source_id: discussion.id,
            source_type: 'Discussion',
            category: 'followed_discussions'
          }
        }
      end
    end
  end

  context 'with the owner' do
    before(:each){ allow(subject).to receive(:current_user).and_return record.user }

    it_behaves_like 'a controller rendering', :index, :show
    it_behaves_like 'a controller restricting',
      destroy: { status: 405, response: :error }

    it_behaves_like 'a controller updating' do
      let(:current_user){ record.user }
      let(:request_params) do
        {
          id: record.id.to_s,
          subscriptions: {
            enabled: false
          }
        }
      end
    end
  end
end
