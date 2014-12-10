require 'spec_helper'

RSpec.describe BoardsController, type: :controller do
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller rendering', Board, :index, :show
end
