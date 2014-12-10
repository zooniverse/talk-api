require 'spec_helper'

RSpec.describe UsersController, type: :controller do
  it_behaves_like 'a controller rescuing'
  
  context 'without an authorized user' do
    it 'should be spec\'d'
  end
  
  context 'with an authorized user' do
    before(:each){ subject.current_user = create :user }
    it_behaves_like 'a controller rendering', User, :index, :show
  end
end
