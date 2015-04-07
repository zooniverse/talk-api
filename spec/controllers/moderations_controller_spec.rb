require 'spec_helper'

RSpec.describe ModerationsController, type: :controller do
  let(:resource){ Moderation }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller restricting',
    create: { status: 401, response: :error },
    update: { status: 401, response: :error }
  
  context 'without an authorized user' do
    before(:each){ allow(subject).to receive(:current_user).and_return create(:user) }
    it_behaves_like 'a controller restricting',
      index: { status: 401, response: :error },
      show: { status: 401, response: :error },
      update: { status: 401, response: :error },
      destroy: { status: 401, response: :error }
  end
  
  context 'with an authorized user' do
    let(:user){ create :moderator, section: 'zooniverse' }
    let(:target){ create :comment }
    before(:each){ allow(subject).to receive(:current_user).and_return user }
    
    it_behaves_like 'a controller rendering', :index, :show, :destroy
    it_behaves_like 'a controller creating' do
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
    
    it_behaves_like 'a controller updating' do
      let(:current_user){ user }
      let(:request_params) do
        {
          id: record.id,
          moderations: {
            actions: [{
              message: 'closing',
              action: 'ignore'
            }]
          }
        }
      end
    end
  end
end
