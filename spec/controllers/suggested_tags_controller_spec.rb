require 'spec_helper'

RSpec.describe SuggestedTagsController, type: :controller do
  let(:resource){ SuggestedTag }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller rendering', :index, :show
  it_behaves_like 'a controller restricting',
    create: { status: 401, response: :error },
    update: { status: 401, response: :error }

  context 'without an authorized user' do
    let(:user){ create :user }
    before(:each){ allow(subject).to receive(:current_user).and_return user }

    it_behaves_like 'a controller rendering', :index, :show
    it_behaves_like 'a controller restricting',
      create: { status: 401, response: :error },
      update: { status: 401, response: :error }
  end

  context 'with an authorized user' do
    let(:user){ create :admin, section: 'zooniverse' }
    before(:each){ allow(subject).to receive(:current_user).and_return user }

    it_behaves_like 'a controller rendering', :index, :show, :destroy
    it_behaves_like 'a controller creating' do
      let(:current_user){ user }
      let(:request_params) do
        {
          suggested_tags: {
            section: 'project-1',
            name: 'tag_name'
          }
        }
      end
    end

    it_behaves_like 'a controller updating' do
      let(:current_user){ user }
      let(:request_params) do
        {
          id: record.id.to_s,
          suggested_tags: {
            name: 'new_name'
          }
        }
      end
    end
  end
end
