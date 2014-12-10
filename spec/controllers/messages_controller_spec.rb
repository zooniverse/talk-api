require 'spec_helper'

RSpec.describe MessagesController, type: :controller do
  it_behaves_like 'a controller', Message
  it_behaves_like 'a controller rescuing'
  
  context 'without an authorized user' do
    it 'should be spec\'d'
  end
  
  context 'with an authorized user' do
    before(:each){ subject.current_user = record.user }
    it_behaves_like 'a controller rendering', Message, :index, :show
  end
end
