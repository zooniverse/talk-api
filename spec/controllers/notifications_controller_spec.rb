require 'spec_helper'

RSpec.describe NotificationsController, type: :controller do
  let(:resource){ Notification }
  it_behaves_like 'a controller'
  it_behaves_like 'a controller authenticating'
  it_behaves_like 'a controller rescuing'
  it_behaves_like 'a controller restricting',
    index: { status: 401, response: :error },
    show: { status: 401, response: :error },
    create: { status: 405, response: :error },
    destroy: { status: 405, response: :error },
    update: { status: 401, response: :error }

  describe '#read' do
    it 'should require authentication' do
      put :read
      expect(response.status).to eql 401
    end
  end

  context 'without an authorized user' do
    let(:user){ create :user }
    before(:each){ allow(subject).to receive(:current_user).and_return user }

    it_behaves_like 'a controller rendering', :index
    it_behaves_like 'a controller restricting',
      show: { status: 401, response: :error },
      create: { status: 405, response: :error },
      destroy: { status: 405, response: :error },
      update: { status: 401, response: :error }

    describe '#read' do
      let!(:notifications){ create_list :notification, 2 }

      it 'should scope updates to the user' do
        put :read, params: { format: :json, id: notifications.map(&:id).join(',') }
        statuses = notifications.map{ |notification| notification.reload.delivered }
        expect(statuses).to all be false
      end
    end
  end

  context 'with an authorized user' do
    before(:each){ allow(subject).to receive(:current_user).and_return record.user }

    it_behaves_like 'a controller rendering', :index, :show
    it_behaves_like 'a controller restricting',
      create: { status: 405, response: :error },
      destroy: { status: 405, response: :error }

    it_behaves_like 'a controller updating' do
      let(:current_user){ record.user }
      let(:request_params) do
        {
          id: record.id.to_s,
          notifications: {
            delivered: true
          }
        }
      end
    end

    describe '#read' do
      let!(:record){ create :notification, section: 'project-1' }
      let!(:record2){ create :notification, user: record.user, section: 'project-1' }
      let!(:record3){ create :notification, user: record.user, section: 'other' }
      let!(:others){ create_list :notification, 2, section: 'project-1' }

      it 'should scope updates to the user with specified ids' do
        put :read, params: { format: :json, id: ([record, record2] + others).map(&:id).join(',') }
        owned_statuses = [record, record2].map{ |notification| notification.reload.delivered }
        expect(owned_statuses).to all be true
      end

      it 'should not update unspecified notifications with specified ids' do
        put :read, params: { format: :json, id: ([record, record2] + others).map(&:id).join(',') }
        expect(record3.reload).to_not be_delivered
      end

      it 'should scope updates to the user with specified ids' do
        put :read, params: { format: :json, id: ([record, record2] + others).map(&:id).join(',') }
        other_statuses = others.map{ |notification| notification.reload.delivered }
        expect(other_statuses).to all be false
      end

      it 'should update all notifications without specified ids' do
        put :read, { format: :json }
        owned_statuses = record.user.notifications.map{ |notification| notification.reload.delivered }
        expect(owned_statuses).to all be true
      end

      it 'should not update other users notifications without specified ids' do
        put :read, { format: :json }
        other_statuses = others.map{ |notification| notification.reload.delivered }
        expect(other_statuses).to all be false
      end

      it 'should scope updates to the user with the specified section' do
        put :read, params: { format: :json, section: 'project-1' }
        section_statuses = [record, record2].map{ |notification| notification.reload.delivered }
        expect(section_statuses).to all be true
      end

      it 'should not update other sections for the user' do
        put :read, params: { format: :json, section: 'project-1' }
        expect(record3.reload).to_not be_delivered
      end

      it 'should not update for other users in the section' do
        put :read, params: { format: :json, section: 'project-1' }
        expect(others.map(&:reload).map(&:delivered)).to all be false
      end
    end
  end
end
