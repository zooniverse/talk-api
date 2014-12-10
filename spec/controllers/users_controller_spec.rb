require 'spec_helper'

RSpec.describe UsersController, type: :controller do
  it_behaves_like 'a controller', User
  it_behaves_like 'a controller rescuing'
  
  context 'without an authorized user' do
    it_behaves_like 'a controller restricting', User,
      index: { status: 401, response: :error }
  end
  
  context 'with an authorized user' do
    before(:each){ subject.current_user = create :user }
    it_behaves_like 'a controller rendering', User, :index, :show
  end
end
