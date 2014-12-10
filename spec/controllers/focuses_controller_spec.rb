require 'spec_helper'

RSpec.describe FocusesController, type: :controller do
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller rendering', Focus, :index, :show
end
