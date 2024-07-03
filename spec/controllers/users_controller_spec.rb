require 'spec_helper'

RSpec.describe UsersController, type: :controller do
  let(:resource){ User }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller restricting',
    create: { status: 405, response: :error },
    destroy: { status: 405, response: :error },
    update: { status: 405, response: :error }

  context 'without an authorized user' do
    it_behaves_like 'a controller rendering', :show
    it_behaves_like 'a controller restricting',
      index: { status: 401, response: :error }
  end

  context 'with an authorized user' do
    before(:each){ allow(subject).to receive(:current_user).and_return create(:user) }
    it_behaves_like 'a controller rendering', :index, :show
  end

  describe '#autocomplete' do
    let!(:user){ create :user, login: 'foo', display_name: 'Somebody' }
    let(:current_user){ nil }
    let(:params){ { } }
    subject{ response }

    before(:each) do
      allow(controller).to receive(:current_user).and_return current_user
      get :autocomplete, params
    end

    context 'without an authorized user' do
      let(:params){ { search: 'f' } }
      it{ is_expected.to be_unauthorized }
    end

    context 'without a search' do
      let(:params){ { } }
      let(:current_user){ create :user }
      it{ is_expected.to be_unprocessable }
    end

    context 'with valid params' do
      let(:params){ { search: 'f' } }
      let(:current_user){ create :user }
      it{ is_expected.to be_successful }

      it 'should return the usernames' do
        expect(response.json[:usernames]).to match_array [{
          'id' => user.id,
          'login' => user.login,
          'display_name' => user.display_name
        }]
      end

      it 'should use the completer' do
        completer = double results: []
        expect(UsernameCompletion).to receive(:new).with(current_user, 'f', limit: 5).and_return completer
        expect(completer).to receive :results
        get :autocomplete, params
      end
    end
  end
end
