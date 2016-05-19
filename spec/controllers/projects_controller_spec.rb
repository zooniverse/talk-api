require 'spec_helper'

RSpec.describe ProjectsController, type: :controller do
  let(:resource){ Project }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller rendering', :index, :show
  it_behaves_like 'a controller restricting',
    create: { status: 405, response: :error },
    destroy: { status: 405, response: :error },
    update: { status: 405, response: :error }
end
