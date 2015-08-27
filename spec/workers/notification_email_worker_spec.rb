require 'spec_helper'

RSpec.describe NotificationEmailWorker, type: :worker do
  let(:worker){ NotificationEmailWorker.new }
  
  describe 'congestion' do
    subject{ worker.sidekiq_options_hash['congestion'] }
    its([:interval]){ is_expected.to eql 1.hour }
    its([:max_in_interval]){ is_expected.to eql 10 }
    its([:min_delay]){ is_expected.to eql 5.minutes }
    its([:reject_with]){ is_expected.to eql :reschedule }
    its([:track_rejected]){ is_expected.to eql false }
    
    it 'should scope the key to be per-user' do
      key = subject[:key].call 123, 'foo'
      expect(key).to eql 'user_123_notification_emails'
    end
  end
  
  describe '#perform' do
    let(:user){ create :user }
    let!(:message_preference){ create :subscription_preference, user: user, category: :messages, email_digest: :daily }
    let!(:mention_preference){ create :subscription_preference, user: user, category: :mentions, email_digest: :daily }
    let(:preferences){ [message_preference, mention_preference] }
    
    before :each do
      allow(User).to receive(:find).with(user.id).and_return user
    end
    
    context 'when no categories exist at this frequency' do
      it 'should not attempt to deliver email' do
        expect(user).to_not receive :notifications
        expect(NotificationMailer).to_not receive :notify
        worker.perform user.id, :weekly
      end
    end
    
    context 'when no enabled categories exist at this frequency' do
      before :each do
        message_preference.update enabled: false
        mention_preference.update enabled: false
      end
      
      it 'should not attempt to deliver email' do
        expect(user).to_not receive :notifications
        expect(NotificationMailer).to_not receive :notify
        worker.perform user.id, :daily
      end
    end
    
    context 'when no undelivered notifications exist' do
      before :each do
        allow(user).to receive_message_chain('notifications.undelivered.joins.where.exists?').and_return false
      end
      
      it 'should not attempt to deliver email' do
        expect(NotificationMailer).to_not receive :notify
        worker.perform user.id, :daily
      end
    end
    
    context 'when undelivered notifications exist' do
      before :each do
        allow(user).to receive_message_chain('notifications.undelivered.joins.where.exists?').and_return true
      end
      
      it 'should attempt to deliver email', :pending do
        mail = double deliver_now!: true
        expect(NotificationMailer).to receive(:notify).with(user, :daily).and_return mail
        expect(mail).to receive :deliver_now!
        worker.perform user.id, :daily
      end
    end
  end
end
