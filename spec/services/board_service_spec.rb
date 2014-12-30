require 'spec_helper'

RSpec.describe BoardService, type: :service do
  it_behaves_like 'a service', Board do
    let(:current_user){ create :user, roles: { test: ['moderator'] } }
    let(:params) do
      {
        boards: {
          title: 'works',
          description: 'works',
          section: 'test'
        }
      }
    end
  end
end
