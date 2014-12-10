require 'spec_helper'

RSpec.describe TagsController, type: :controller do
  let(:resource){ Tag }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller rendering', :index, :show
end
