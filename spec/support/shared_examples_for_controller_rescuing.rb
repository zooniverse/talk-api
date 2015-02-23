require 'spec_helper'

RSpec.shared_examples_for 'ActionRescuing' do |exception, with: nil|
  controller described_class do
    define_method :index do
      raise exception
    end
  end
  
  describe "#{ exception } exceptions" do
    it "should respond with #{ with }" do
      get :index
      expect(response.status).to eql with
    end
    
    it 'should report the error message' do
      get :index
      expect(response.json[:error]).to eql exception.to_s
    end
  end
end

RSpec.shared_examples_for 'a controller rescuing' do
  it_behaves_like 'ActionRescuing',
    ActiveRecord::RecordNotFound.new, with: 404
  
  it_behaves_like 'ActionRescuing',
    ActionController::UnpermittedParameters.new(['foo']), with: 422
  
  it_behaves_like 'ActionRescuing',
    TalkService::ParameterError.new, with: 422
  
  it_behaves_like 'ActionRescuing',
    ActionController::RoutingError.new('foo'), with: 404
  
  it_behaves_like 'ActionRescuing',
    Pundit::AuthorizationNotPerformedError.new, with: 501
  
  it_behaves_like 'ActionRescuing',
    Pundit::PolicyScopingNotPerformedError.new, with: 501
  
  it_behaves_like 'ActionRescuing',
    Pundit::NotDefinedError.new, with: 501
  
  it_behaves_like 'ActionRescuing',
    Pundit::NotAuthorizedError.new, with: 401
  
  it_behaves_like 'ActionRescuing',
    ActiveRecord::RecordNotDestroyed.new('foo'), with: 401
  
  it_behaves_like 'ActionRescuing',
    ActionController::ParameterMissing.new('foo'), with: 422
end
