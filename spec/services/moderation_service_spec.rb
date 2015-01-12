require 'spec_helper'

RSpec.describe ModerationService, type: :service do
  it_behaves_like 'a service', Moderation do
    let(:target){ create :comment }
    let(:create_params) do
      {
        moderations: {
          section: 'test',
          target_id: target.id,
          target_type: target.class.name,
          reports: [{
            message: 'works'
          }]
        }
      }
    end
    
    context 'creating a moderation' do
      before(:each){ service.create }
      subject!{ service.resource }
      
      its(:target){ is_expected.to eql target }
      its(:section){ is_expected.to eql 'test' }
      its(:reports){ is_expected.to include 'message' => 'works', 'user_id' => current_user.id }
      
      context 'when the target is already reported' do
        before(:each) do
          service.create
          service.resource.closed!
          service.resource = nil
        end
        
        it 'should not create multiple records' do
          expect{ service.create }.to_not change{ Moderation.count }
        end
        
        it 'should add the report' do
          service.create
          expect(subject.reload.reports.length).to eql 2
        end
        
        it 'should reopen the moderation' do
          service.create
          expect(subject.reload).to be_opened
        end
      end
    end
    
    context 'when actioning a moderation' do
      let(:current_user){ create :user, roles: { test: ['moderator'] } }
      
      it_behaves_like 'a service updating' do
        let(:update_params) do
          {
            id: record.id,
            moderations: {
              actions: [{
                message: 'closing',
                state: 'closed'
              }]
            }
          }
        end
        
        it 'should add the action' do
          service.update
          expect(service.resource.actions).to include({
            'message' => 'closing',
            'state' => 'closed',
            'user_id' => current_user.id
          })
        end
        
        it 'should set the moderation state' do
          service.update
          expect(service.resource).to be_closed
        end
      end
    end
  end
end
