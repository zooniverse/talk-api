require 'spec_helper'

RSpec.describe CommentService, type: :service do
  it_behaves_like 'a service', Comment do
    let(:params) do
      {
        comments: {
          body: 'works',
          discussion_id: create(:discussion).id
        }
      }
    end
  end
end
