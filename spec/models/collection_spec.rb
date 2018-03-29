require 'spec_helper'

RSpec.describe Collection, type: :model do
  it_behaves_like 'moderatable'
  it_behaves_like 'a searchable interface'
end
