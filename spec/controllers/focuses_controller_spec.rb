require 'spec_helper'

RSpec.describe FocusesController, type: :controller do
  let(:resource){ Focus }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller rendering', :index, :show
  it_behaves_like 'a controller restricting',
    create: { status: 401, response: :error },
    destroy: { status: 401, response: :error },
    update: { status: 401, response: :error }
end
