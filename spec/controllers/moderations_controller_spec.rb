require 'spec_helper'

RSpec.describe ModerationsController, type: :controller do
  let(:resource){ Moderation }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller restricting',
    create: { status: 401, response: :error }
  
  context 'without an authorized user' do
    before(:each){ allow(subject).to receive(:current_user).and_return create(:user) }
    it_behaves_like 'a controller restricting',
      index: { status: 401, response: :error },
      show: { status: 401, response: :error },
      destroy: { status: 401, response: :error }
  end
  
  context 'with an authorized user' do
    let(:user){ create :user, roles: { zooniverse: ['moderator'] } }
    before(:each){ allow(subject).to receive(:current_user).and_return user }
    it_behaves_like 'a controller rendering', :index, :show, :destroy
    it_behaves_like 'a controller creating' do
      let(:target){ create :comment }
      let(:request_params) do
        {
          moderations: {
            section: 'test',
            target_id: target.id,
            target_type: 'Comment',
            reports: [{
              message: 'works'
            }]
          }
        }
      end
    end
  end
end
