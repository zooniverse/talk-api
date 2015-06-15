require 'spec_helper'

RSpec.describe ModerationService, type: :service do
  it_behaves_like 'a service', Moderation do
    let(:target){ create :comment }
    let(:create_params) do
      {
        moderations: {
          section: 'project-1',
          target_id: target.id,
          target_type: target.class.name,
          reports: [{
            message: 'works'
          }]
        }
      }
    end
    
    it_behaves_like 'a service creating', Moderation
    
    context 'creating a moderation' do
      before(:each){ service.create }
      subject!{ service.resource }
      
      its(:target){ is_expected.to eql target }
      its(:section){ is_expected.to eql 'project-1' }
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
      let(:current_user){ create :moderator }
      
      it_behaves_like 'a service updating', Moderation do
        let(:update_params) do
          {
            id: record.id,
            moderations: {
              actions: [{
                action: 'ignore',
                message: 'closing'
              }]
            }
          }
        end
        
        it 'should add the action' do
          service.update
          expect(service.resource.actions).to include({
            'action' => 'ignore',
            'message' => 'closing',
            'user_id' => current_user.id
          })
        end
        
        it 'should set the moderation state' do
          service.update
          expect(service.resource).to be_ignored
        end
        
        it 'should ensure the action is permitted' do
          expect_any_instance_of(ModerationPolicy)
            .to receive(:can_action?).with('ignore')
            .and_call_original
          service.update
        end
      end
    end
  end
end
