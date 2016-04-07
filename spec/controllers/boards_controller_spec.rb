require 'spec_helper'

RSpec.describe BoardsController, type: :controller do
  let(:resource){ Board }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller rendering', :index, :show

  context 'without an authorized user' do
    let(:user){ create :user }
    before(:each){ allow(subject).to receive(:current_user).and_return user }

    it_behaves_like 'a controller restricting',
      create: { status: 401, response: :error },
      destroy: { status: 401, response: :error },
      update: { status: 401, response: :error }
  end

  context 'with an authorized user' do
    let(:user){ create :moderator, section: 'zooniverse' }
    before(:each){ allow(subject).to receive(:current_user).and_return user }
    it_behaves_like 'a controller rendering', :destroy
    it_behaves_like 'a controller creating' do
      let(:current_user){ user }
      let(:request_params) do
        {
          boards: {
            title: 'works',
            description: 'works',
            section: 'project-1',
            permissions: { read: 'all', write: 'all' }
          }
        }
      end
    end

    it_behaves_like 'a controller updating' do
      let(:current_user){ user }
      let(:request_params) do
        {
          id: record.id.to_s,
          boards: {
            title: 'changed'
          }
        }
      end
    end
  end
end
