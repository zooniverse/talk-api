require 'spec_helper'

RSpec.describe Subject, type: :model do
  let(:subject){ create :subject }
  it_behaves_like 'moderatable'
end
