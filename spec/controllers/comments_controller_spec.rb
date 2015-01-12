require 'spec_helper'

RSpec.describe CommentsController, type: :controller do
  let(:resource){ Comment }
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
    
    it_behaves_like 'a controller restricting',
      destroy: { status: 401, response: :error }
  end
  
  context 'with an authorized user' do
    let(:record){ create :comment }
    let(:user){ record.user }
    before(:each){ allow(subject).to receive(:current_user).and_return user }
    
    it_behaves_like 'a controller rendering', :destroy
    it_behaves_like 'a controller creating' do
      let(:request_params) do
        {
          comments: {
            body: 'works',
            discussion_id: create(:discussion).id
          }
        }
      end
    end
  end
end
