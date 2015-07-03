require 'spec_helper'

RSpec.describe CommentsController, type: :controller do
  let(:resource){ Comment }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller rendering', :index, :show
  it_behaves_like 'a controller restricting',
    create: { status: 401, response: :error },
    update: { status: 401, response: :error },
    upvote: { status: 401, response: :error },
    remove_upvote: { status: 401, response: :error }
  
  context 'without an authorized user' do
    let(:user){ create :user }
    before(:each){ allow(subject).to receive(:current_user).and_return user }
    
    it_behaves_like 'a controller restricting',
      destroy: { status: 401, response: :error },
      upvote: { status: 401, response: :error },
      remove_upvote: { status: 401, response: :error }
  end
  
  context 'with an authorized user' do
    let(:record){ create :comment }
    let(:user){ record.user }
    before(:each){ allow(subject).to receive(:current_user).and_return user }
    
    it_behaves_like 'a controller rendering', :destroy
    it_behaves_like 'a controller restricting',
      upvote: { status: 401, response: :error },
      remove_upvote: { status: 401, response: :error }
    
    it_behaves_like 'a controller creating' do
      let(:request_params) do
        {
          comments: {
            body: 'works',
            discussion_id: create(:discussion).id.to_s
          }
        }
      end
    end
    
    it_behaves_like 'a controller updating' do
      let(:current_user){ user }
      let(:request_params) do
        {
          id: record.id.to_s,
          comments: {
            body: 'changed'
          }
        }
      end
    end
  end
  
  context 'with a non-author user' do
    let(:record){ create :comment }
    let(:user){ create :user }
    let(:send_request){ put upvote_method, id: record.id.to_s, format: :json }
    before(:each){ allow(subject).to receive(:current_user).and_return user }
    
    it_behaves_like 'a controller restricting',
      update: { status: 401, response: :error },
      destroy: { status: 401, response: :error }
    
    shared_examples_for 'a CommentsController upvoting' do
      it 'should find the resource' do
        expect_any_instance_of(subject.service_class).to receive :find_resource
        send_request
      end
      
      it 'should authorize the action' do
        expect_any_instance_of(subject.service_class).to receive :authorize
        send_request
      end
      
      it 'should serialize the resource' do
        expect(subject.serializer_class).to receive(:resource).and_call_original
        send_request
      end
      
      context 'with a response' do
        before(:each){ send_request }
        
        it 'should set the correct status' do
          expect(response.status).to eql 200
        end
        
        it 'should be json' do
          expect(response.content_type).to eql 'application/json'
        end
        
        it 'should be an object' do
          expect(response.json).to be_a Hash
        end
      end
    end
    
    describe '#upvote' do
      let(:upvote_method){ :upvote }
      
      it_behaves_like 'a CommentsController upvoting' do
        it 'should update the record' do
          expect{
            send_request
          }.to change{
            record.reload.upvotes
          }.from({
            
          }).to user.login => kind_of(String)
        end
      end
    end
    
    describe '#remove_upvote' do
      let(:record){ create :comment, upvotes: { user.login => Time.now.to_i } }
      let(:upvote_method){ :remove_upvote }
      
      it_behaves_like 'a CommentsController upvoting' do
        it 'should update the record' do
          expect{
            send_request
          }.to change{
            record.reload.upvotes
          }.from({
            user.login => kind_of(String)
          }).to({ })
        end
      end
    end
  end
end
