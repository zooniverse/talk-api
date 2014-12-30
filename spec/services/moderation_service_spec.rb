require 'spec_helper'

RSpec.describe ModerationService, type: :service do
  it_behaves_like 'a service', Moderation do
    let(:params) do
      {
        moderations: {
          section: 'test',
          target_id: create(:comment).id,
          target_type: 'Comment',
          reports: [{
            message: 'works'
          }]
        }
      }
    end
  end
end
