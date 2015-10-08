require 'spec_helper'

RSpec.describe ModerationsController, type: :controller do
  let(:resource){ Moderation }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller restricting',
    create: { status: 401, response: :error },
    update: { status: 401, response: :error }
  
  context 'without an authorized user' do
    before(:each){ allow(subject).to receive(:current_user).and_return create(:user) }
    it_behaves_like 'a controller rendering', :index
    it_behaves_like 'a controller restricting',
      show: { status: 401, response: :error },
      update: { status: 401, response: :error },
      destroy: { status: 401, response: :error }
  end
  
  context 'with an authorized user' do
    let(:user){ create :moderator, section: 'zooniverse' }
    let(:target){ create :comment }
    before(:each){ allow(subject).to receive(:current_user).and_return user }
    
    it_behaves_like 'a controller rendering', :index, :show, :destroy
    
    context 'filtering by state' do
      let(:state){ nil }
      let(:response_state){ response.json[:moderations].first[:state] }
      
      before(:each) do
        create :moderation, :closed
        create :moderation, :watched
        get :index, state: state, format: :json
      end
      
      context 'with a valid state' do
        let(:state){ 'watched' }
        
        it 'should filter' do
          expect(response_state).to eql 'watched'
        end
      end
      
      context 'with an invalid state' do
        let(:state){ 'foo' }
        
        it 'should be unprocessable' do
          expect(response).to be_unprocessable
        end
        
        it 'should list the expected states' do
          message = response.json[:error]
          expect(message).to eql "Expected state to be in #{ Moderation.states.keys }, but was foo"
        end
      end
    end
    
    it_behaves_like 'a controller creating' do
      let(:request_params) do
        {
          moderations: {
            section: 'project-1',
            target_id: target.id.to_s,
            target_type: 'Comment',
            reports: [{
              message: 'works'
            }]
          }
        }
      end
    end
    
    context 'when the target is already reported' do
      before(:each) do
        create :reported_comment, target: target, message: 'first', user: first_user
        post :create, request_params.merge(format: :json)
      end
      
      let(:first_user){ create :user }
      let(:request_params) do
        {
          moderations: {
            section: 'project-1',
            target_id: target.id.to_s,
            target_type: 'Comment',
            reports: [{
              message: 'second'
            }]
          }
        }
      end
      let(:create_response){ response.json['moderations'].first }
      let(:reports){ Moderation.find(create_response['id']).reports }
      
      it 'should have two reports' do
        expect(reports.length).to eql 2
      end
      
      it 'should set the first report' do
        expect(reports.first).to eql 'message' => 'first', 'user_id' => first_user.id
      end
      
      it 'should set the second report' do
        expect(reports.second).to eql 'message' => 'second', 'user_id' => user.id
      end
      
      it 'should sanitize the response' do
        expect(create_response.keys).to match_array %w(href id links project_id section state target target_id target_type updated_at)
      end
    end
    
    it_behaves_like 'a controller updating' do
      let(:current_user){ user }
      let(:request_params) do
        {
          id: record.id.to_s,
          moderations: {
            actions: [{
              message: 'closing',
              action: 'ignore'
            }]
          }
        }
      end
    end
  end
end
