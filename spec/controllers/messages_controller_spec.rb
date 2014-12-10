require 'spec_helper'

RSpec.describe MessagesController, type: :controller do
  it_behaves_like 'a controller', Message
  it_behaves_like 'a controller rescuing'
  
  context 'without an authorized user' do
    let(:user){ create :user }
    before(:each){ subject.current_user = user }
    
    it_behaves_like 'a controller restricting', Message,
      index: { status: 200, response: :empty },
      show: { status: 401, response: :error }
  end
  
  context 'with an authorized user' do
    before(:each){ subject.current_user = record.user }
    it_behaves_like 'a controller rendering', Message, :index, :show
  end
end
