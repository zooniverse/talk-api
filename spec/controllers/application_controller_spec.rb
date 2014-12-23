require 'spec_helper'

RSpec.describe ApplicationController, type: :controller do
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller authenticating', :root
end
