require 'spec_helper'

RSpec.describe CommentService, type: :service do
  it_behaves_like 'a service', Comment do
    let(:create_params) do
      {
        comments: {
          body: 'works',
          discussion_id: create(:discussion).id
        }
      }
    end
    
    context 'creating the comment' do
      before(:each){ service.create }
      subject{ service.resource }
      its(:user){ is_expected.to eql current_user }
    end
    
    it_behaves_like 'a service creating', 'Comment'
    it_behaves_like 'a service updating', Comment do
      let(:record){ create :comment, user: current_user }
      let(:update_params) do
        {
          id: record.id,
          comments: {
            body: 'changed'
          }
        }
      end
    end
    
    shared_examples_for 'a CommentService upvoting' do
      let(:record){ create :comment }
      let(:options) do
        {
          params: ActionController::Parameters.new(id: record.id),
          action: upvote_method,
          current_user: current_user
        }
      end
      
      it 'should find the resource' do
        expect(service.model_class).to receive(:find)
          .with(record.id).twice.and_call_original
        service.send upvote_method
      end
      
      it 'should authorize the action' do
        expect(service).to receive(:authorize).once.and_call_original
        2.times{ service.send upvote_method }
      end
      
      it 'should update the record attributes' do
        service.find_resource
        expect(service.resource).to receive(:"#{ upvote_method }!").once.and_call_original
        service.send upvote_method
      end
    end
    
    describe '#upvote' do
      it_behaves_like 'a CommentService upvoting'
      let(:upvote_method){ :upvote }
    end
    
    describe '#remove_upvote' do
      it_behaves_like 'a CommentService upvoting'
      let(:upvote_method){ :remove_upvote }
    end
  end
end
