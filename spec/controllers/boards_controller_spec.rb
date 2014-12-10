require 'spec_helper'

RSpec.describe BoardsController, type: :controller do
  let(:resource){ Board }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller rendering', :index, :show
end
