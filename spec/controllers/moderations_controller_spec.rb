require 'spec_helper'

RSpec.describe ModerationsController, type: :controller do
  it_behaves_like 'a controller', Moderation
  it_behaves_like 'a controller rescuing'
  
  context 'without an authorized user' do
    before(:each){ subject.current_user = create :user }
    it_behaves_like 'a controller restricting', Moderation,
      index: { status: 401, response: :error },
      show: { status: 401, response: :error }
  end
  
  context 'with an authorized user' do
    before(:each){ subject.current_user = create :user, roles: { zooniverse: ['moderator'] } }
    it_behaves_like 'a controller rendering', Moderation, :index, :show
  end
end
