require 'spec_helper'

RSpec.describe Moderation, type: :model do
  it_behaves_like 'a notifiable model'
  
  context 'validating' do
    it 'should require a target' do
      without_target = build :moderation, target: nil
      expect(without_target).to fail_validation target: "can't be blank"
    end
    
    it 'should require a section' do
      without_section = build :moderation, section: nil
      expect(without_section).to fail_validation section: "can't be blank"
    end
  end
  
  context 'initializing' do
    it 'should accept a polymorphic target' do
      user = create :user
      moderation = create :moderation, target: user
      expect(moderation.target_id).to eql user.id
      expect(moderation.target_type).to eql 'User'
    end
  end
  
  context 'with state' do
    it 'should be opened by default' do
      moderation = create :moderation
      expect(moderation).to be_opened
    end
    
    it 'should update actioned_at when actioning' do
      moderation = create :moderation
      moderator = create :moderator
      expect {
        moderation.actions << {
          user_id: moderator.id,
          message: 'closing',
          action: 'ignore'
        }
        moderation.save
      }.to change {
        moderation.actioned_at
      }
    end
  end
  
  context 'applying an action' do
    let(:target){ create :comment }
    let(:moderator){ create :moderator }
    subject{ create :moderation, target: target }
    let(:action_param) do
      {
        user_id: moderator.id,
        message: 'actioning'
      }
    end
    
    before(:each) do
      subject.actions << action
      subject.save!
      subject.reload
    end
    
    context 'when destroying' do
      let(:action){ action_param.merge action: 'destroy' }
      its(:state){ is_expected.to eql 'closed' }
      its(:target){ is_expected.to be_nil }
      its(:destroyed_target){ is_expected.to include 'id' => target.id }
    end
    
    context 'when ignoring' do
      let(:action){ action_param.merge action: 'ignore' }
      its(:state){ is_expected.to eql 'ignored' }
    end
    
    context 'when watching' do
      let(:action){ action_param.merge action: 'watch' }
      its(:state){ is_expected.to eql 'watched' }
    end
  end
  
  RSpec.shared_context 'moderation subscriptions' do
    let(:moderation){ create :moderation, section: 'project-1' }
    let!(:moderators){ create_list :moderator, 2, section: 'project-1' }
    let!(:other_moderators){ create_list :moderator, 2, section: 'project-2' }
    
    let!(:admins){ create_list :admin, 2, section: 'project-1' }
    let!(:other_admins){ create_list :admin, 2, section: 'project-2' }
    
    let!(:users){ create_list :user, 2 }
    
    let(:notifications){ Notification.where subscription: subscriptions }
    let(:subscriptions) do
      Subscription.moderation_reports.where source: moderation, user: moderators + admins
    end
    
    let(:subscribed_users){ subscriptions.map &:user }
  end
  
  describe '#notify_subscribers_later' do
    include_context 'moderation subscriptions'
    
    it 'should queue the notification' do
      expect(ModerationNotificationWorker).to receive(:perform_async).with moderation.id
      moderation.run_callbacks :commit
    end
  end
  
  describe '#notify_subscribers' do
    before(:each) do
      admins.each do |admin|
        admin.preference_for(:moderation_reports).update_attributes enabled: false
      end
    end
    include_context 'moderation subscriptions'
    before(:each){ moderation.notify_subscribers }
    
    it 'should create notifications for subscribed users' do
      notified_users = notifications.reload.collect &:user
      expect(notified_users).to match_array moderators
    end
    
    it 'should not create notifications for unsubscribed users' do
      expect(Notification.where(user: admins).exists?).to be false
    end
    
    context 'notification' do
      subject{ notifications.first }
      its(:user){ is_expected.to be_in moderators }
      its(:message){ is_expected.to eql "A comment has been reported" }
      its(:url){ is_expected.to eql FrontEnd.link_to(moderation) }
      its(:source){ is_expected.to eql moderation }
      its(:section){ is_expected.to eql 'project-1' }
    end
  end
  
  describe '#moderators' do
    include_context 'moderation subscriptions'
    subject{ moderation.moderators }
    it{ is_expected.to match_array moderators + admins }
  end
  
  describe '#subscribe_users' do
    include_context 'moderation subscriptions'
    
    context 'when the preference is enabled' do
      it 'should subscribe moderators' do
        expect(subscribed_users).to match_array moderators + admins
      end
    end
    
    context 'when the preference is disabled' do
      before(:each) do
        admins.each do |admin|
          admin.preference_for(:moderation_reports).update_attributes enabled: false
        end
      end
      
      it 'should not subscribe the moderator' do
        expect(subscribed_users).to match_array moderators
      end
    end
  end
end
