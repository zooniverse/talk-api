require 'spec_helper'

RSpec.describe Project, type: :model do
  it_behaves_like 'a subscribable model'
end
