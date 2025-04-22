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
        its(:user_ip){ is_expected.to eql '1.2.3.4' }
      end
    end

    context 'with a focused comment' do
      context 'with a related focus to project board' do
        let(:project_board) { create :board, section: 'project-212' }
        let(:related_project) { create :project, id: 212}
        let(:focus) { create :subject, project: related_project }
        let(:create_params) do
          {
            discussions: {
              title: 'works',
              board_id: project_board.id,
              comments: [{
                body: 'works',
                focus_id: focus.id,
                focus_type: 'Subject'
              }]
            }
          }
        end

        it 'should set focus of discussion and comment' do
          service.create
          created_discussion = service.resource
          expect(created_discussion.focus).to eq(focus)
          expect(created_discussion.comments.first.focus).to eq(focus)
        end
      end

      context 'with focus validation' do
        let(:project_unrelated_to_board) { create :project, id: 101 }
        let(:subject_unrelated_to_board) { create :subject, project: project_unrelated_to_board }
        let(:create_params) do
          {
            discussions: {
              title: 'works',
              board_id: board.id,
              comments: [{
                body: 'works',
                focus_id: subject_unrelated_to_board.id,
                focus_type: 'Subject'
              }]
            }
          }
        end

        it 'should not create discussion or comment if focus is not a subject to board project' do
          expect { service.create }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Focus Subject must belong to project')
        end
      end
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
      let(:record){ create :discussion }
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
