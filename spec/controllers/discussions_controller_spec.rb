require 'spec_helper'

RSpec.describe DiscussionsController, type: :controller do
  let(:resource){ Discussion }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller rendering', :index, :show
end
