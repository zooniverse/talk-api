require 'spec_helper'

RSpec.describe SubscriptionService, type: :service do
  it_behaves_like 'a service', Subscription do
    let(:discussion){ create :discussion }
    let(:create_params) do
      {
        subscriptions: {
          source_id: discussion.id,
          source_type: 'Discussion',
          category: 'followed_discussions'
        }
      }
    end

    it_behaves_like 'a service creating', Subscription
    it_behaves_like 'a service updating', Subscription do
      let(:current_user){ record.user }
      let(:update_params) do
        {
          id: record.id,
          subscriptions: {
            enabled: false
          }
        }
      end
    end
  end
end
