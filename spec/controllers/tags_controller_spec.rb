require 'spec_helper'

RSpec.describe TagsController, type: :controller do
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller rendering', Tag, :index, :show
end
