require 'spec_helper'

RSpec.describe DiscussionService, type: :service do
  it_behaves_like 'a service', Discussion do
    let(:current_user){ create :moderator, section: 'zooniverse' }
    let(:board){ create :board }
    let(:create_params) do
      {
        discussions: {
          title: 'works',
          board_id: board.id,
          comments: [{
            body: 'works'
          }]
        }
      }
    end
    
    it_behaves_like 'a service creating', Discussion
    
    context 'creating the discussion' do
      before(:each){ service.create }
      subject{ service.resource }
      its(:title){ is_expected.to eql 'works' }
      its(:board){ is_expected.to eql board }
      its(:user){ is_expected.to eql current_user }
      
      context 'with a comment' do
        subject{ service.resource.comments.first }
        its(:body){ is_expected.to eql 'works' }
        its(:discussion){ is_expected.to eql service.resource }
        its(:user){ is_expected.to eql current_user }
      end
    end
    
    context 'with a focused comment' do
      let(:focus){ create :subject }
      let(:create_params) do
        {
          discussions: {
            title: 'works',
            board_id: board.id,
            comments: [{
              body: 'works',
              focus_id: focus.id,
              focus_type: 'Subject'
            }]
          }
        }
      end
      
      before(:each){ service.create }
      subject{ service.resource }
      
      its(:focus){ is_expected.to eql focus }
      its('comments.first.focus'){ is_expected.to eql focus }
    end
    
    it_behaves_like 'a service updating', Discussion do
      let(:update_params) do
        {
          id: record.id,
          discussions: {
            title: 'changed'
          }
        }
      end
    end
    
    describe '#update' do
      let(:resource){ Discussion }
      let(:creation_service){ described_class.new **create_options }
      let(:record){ create resource }
      let(:params){ update_params }
      let(:options){ update_options }
      let(:current_user){ record.user }
      
      let(:update_params) do
        {
          id: record.id,
          discussions: {
            title: 'changed'
          }
        }
      end
      
      it 'should set the action to owner_update' do
        expect {
          service.update
        }.to change {
          service.action
        }.to :owner_update
      end
      
      context 'with a moderator' do
        let!(:role){ current_user.roles.create section: record.section, name: 'moderator' }
        
        it 'should not change the action' do
          expect {
            service.update
          }.to_not change {
            service.action
          }
        end
      end
      
      context 'with an admin' do
        let!(:role){ current_user.roles.create section: record.section, name: 'admin' }
        
        it 'should not change the action' do
          expect {
            service.update
          }.to_not change {
            service.action
          }
        end
      end
    end
  end
end
