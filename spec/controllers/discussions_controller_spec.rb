require 'spec_helper'

RSpec.describe DiscussionsController, type: :controller do
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller rendering', Discussion, :index, :show
end
