require 'spec_helper'

RSpec.describe CommentsController, type: :controller do
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller rendering', Comment
end
