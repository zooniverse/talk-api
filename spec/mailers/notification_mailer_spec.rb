require 'spec_helper'

RSpec.describe NotificationMailer, type: :mailer do
  let(:frequency){ :immediate }
  let(:mailer){ NotificationMailer.send :new }
  let(:project){ create :project }
  let(:section){ "project-#{ project.id }" }
  
  let!(:user1){ create :user }
  let!(:user2){ create :user }
  
  let!(:mention_preference){ user1.preference_for(:mentions).update email_digest: :immediate }
  let!(:system_preference){ user1.preference_for(:system).update email_digest: :immediate }
  let!(:participating_preference){ user1.preference_for(:participating_discussions).update email_digest: :daily }
  let!(:message_preference){ user1.preference_for(:messages).update email_digest: :weekly }
  
  let(:board){ create :board, section: section }
  let!(:discussion){ create :discussion, board: board, user: user1 }
  let!(:comment){ create :comment, discussion: discussion, user: user1 }
  let!(:reply_comment){ create :comment, user: user2, discussion: discussion, body: "Hey @#{ user1.login }" }
  
  let(:zooniverse_board){ create :board, section: 'zooniverse' }
  let!(:zooniverse_discussion){ create :discussion, board: zooniverse_board, user: user1 }
  let!(:zooniverse_comment){ create :comment, discussion: zooniverse_discussion, user: user1 }
  let!(:zooniverse_reply_comment){ create :comment, discussion: zooniverse_discussion, user: user2, body: "Hey @#{ user1.login }" }
  
  let!(:data_request){ create :data_request, user: user1, section: section }
  let!(:conversation){ create :conversation_with_messages, user: user2, recipients: [user1], message_count: 2 }
  
  before :each do
    Mention.all.each &:notify_mentioned
    Comment.all.each &:notify_subscribers
    data_request.notify_user url: 'foo', message: 'bar'
    conversation.messages.each &:notify_subscribers
  end
  
  describe '#notify' do
    RSpec.shared_examples_for 'NotificationMailer#notify' do
      let(:mailer){ NotificationMailer.send :new, :notify, user1, frequency }
      let(:frequency_int){ SubscriptionPreference.email_digests[frequency] }
      let(:mail){ mailer.notify user1, frequency }
      
      before(:each) do
        stub_request(:post, 'http://markdown.localhost/html').to_return status: 200, body: 'some markdown', headers: { }
        mailer.instance_variable_set :@notifications, Notification.where(user: user1).all.to_a
        expect(mailer).to receive(:normalize_frequency).with(frequency).and_call_original
        expect(mailer).to receive(:find_categories_for).with(frequency_int).and_return categories
        expect(mailer).to receive(:find_notifications_for).with categories
        expect(mailer).to receive(:organize).and_call_original
      end
      
      it 'should send an email' do
        expect{
          mail.deliver
        }.to change {
          ActionMailer::Base.deliveries.count
        }.by 1
      end
      
      it 'should address the email' do
        expect(mail.to).to eql [user1.email]
        expect(mail.from).to eql ['no-reply@zooniverse.org']
      end
    end
    
    context 'with immediate' do
      it_behaves_like 'NotificationMailer#notify' do
        let(:frequency){ :immediate }
        let(:categories){ %w(mentions system) }
      end
    end
    
    context 'with daily' do
      it_behaves_like 'NotificationMailer#notify' do
        let(:frequency){ :daily }
        let(:categories){ %w(participating_discussions) }
      end
    end
    
    context 'with weekly' do
      it_behaves_like 'NotificationMailer#notify' do
        let(:frequency){ :weekly }
        let(:categories){ %w(messages) }
      end
    end
  end
  
  describe '#find_categories_for' do
    before(:each){ mailer.instance_variable_set :@user, user1 }
    let(:categories){ mailer.find_categories_for SubscriptionPreference.email_digests[frequency] }
    
    context 'with immediate' do
      let(:frequency){ :immediate }
      subject{ categories }
      it{ is_expected.to match_array Subscription.categories.values_at(:mentions, :system) }
    end
    
    context 'with daily' do
      let(:frequency){ :daily }
      subject{ categories }
      it{ is_expected.to match_array Subscription.categories.values_at(:participating_discussions) }
    end
    
    context 'with weekly' do
      let(:frequency){ :weekly }
      subject{ categories }
      it{ is_expected.to match_array Subscription.categories.values_at(:messages) }
    end
    
    context 'with disabled preferences' do
      let(:frequency){ :daily }
      before(:each){ user1.preference_for(:participating_discussions).update enabled: false }
      subject{ categories }
      it{ is_expected.to be_empty }
    end
  end
  
  describe '#find_notifications_for' do
    before(:each){ mailer.instance_variable_set :@user, user1 }
    let(:notifications){ mailer.find_notifications_for categories }
    let(:subscriptions){ notifications.map &:subscription }
    let(:notification_categories){ subscriptions.map &:category }
    
    context 'with immediate' do
      let(:frequency){ :immediate }
      subject{ notification_categories }
      
      let(:categories){ [1, 3] }
      its(:uniq){ is_expected.to match_array %w(mentions system) }
      its(:length){ is_expected.to eql 3 }
    end
    
    context 'with daily' do
      let(:frequency){ :daily }
      subject{ notification_categories }
      
      let(:categories){ [0] }
      its(:uniq){ is_expected.to match_array %w(participating_discussions) }
      its(:length){ is_expected.to eql 2 }
    end
    
    context 'with weekly' do
      let(:frequency){ :weekly }
      subject{ notification_categories }
      let(:categories){ [2] }
      its(:uniq){ is_expected.to match_array %w(messages) }
      its(:length){ is_expected.to eql 2 }
    end
  end
  
  describe '#organize' do
    before(:each) do
      mailer.instance_variable_set :@notifications, Notification.where(user: user1).all.to_a
      mailer.organize
    end
    
    context 'messages' do
      let(:messages){ mailer.instance_variable_get :@messages }
      subject{ messages }
      its('keys.first'){ is_expected.to eql conversation }
      
      context 'notifications' do
        subject{ messages[conversation].map &:source }
        it{ is_expected.to match_array conversation.messages }
        its(:length){ is_expected.to eql 2 }
      end
    end
    
    context 'mentions' do
      let(:mentions){ mailer.instance_variable_get :@mentions }
      subject{ mentions }
      
      its(:keys){ is_expected.to match_array [section, 'zooniverse'] }
      
      context 'project notifications' do
        subject{ mentions[section].map &:source }
        it{ is_expected.to eql [reply_comment] }
      end
      
      context 'zooniverse notifications' do
        subject{ mentions['zooniverse'].map &:source }
        it{ is_expected.to eql [zooniverse_reply_comment] }
      end
    end
    
    context 'system' do
      let(:system){ mailer.instance_variable_get :@system }
      subject{ system }
      
      its(:keys){ is_expected.to match_array [section] }
      
      context 'notifications' do
        subject{ system[section].map &:source }
        it{ is_expected.to eql [data_request] }
      end
    end
    
    context 'participating' do
      let(:participating){ mailer.instance_variable_get :@participating }
      subject{ participating }
      
      its(:keys){ is_expected.to match_array [section, 'zooniverse'] }
      
      context 'project notifications' do
        subject{ participating[section][discussion].map &:source }
        it{ is_expected.to eql [reply_comment] }
      end
      
      context 'zooniverse notifications' do
        subject{ participating['zooniverse'][zooniverse_discussion].map &:source }
        it{ is_expected.to eql [zooniverse_reply_comment] }
      end
    end
  end
  
  describe '#select_category' do
    before(:each){ mailer.instance_variable_set :@notifications, Notification.where(user: user1).all.to_a }
    let(:category_notifications){ mailer.select_category category }
    let(:category_subscriptions){ category_notifications.map &:subscription }
    subject{ category_subscriptions.map &:category }
    
    context 'with participating_discussions' do
      let(:category){ 'participating_discussions' }
      its(:uniq){ is_expected.to eql [category] }
      its(:length){ is_expected.to eql 2 }
    end
    
    context 'with mentions' do
      let(:category){ 'mentions' }
      its(:uniq){ is_expected.to eql [category] }
      its(:length){ is_expected.to eql 2 }
    end
    
    context 'with messages' do
      let(:category){ 'mentions' }
      its(:uniq){ is_expected.to eql [category] }
      its(:length){ is_expected.to eql 2 }
    end
    
    context 'with system' do
      let(:category){ 'system' }
      its(:uniq){ is_expected.to eql [category] }
      its(:length){ is_expected.to eql 1 }
    end
  end
  
  describe '#set_delivered' do
    before(:each){ mailer.instance_variable_set :@notifications, Notification.all.to_a }
    
    it 'should set notificiations as delivered' do
      expect {
        mailer.set_delivered
      }.to change {
        Notification.undelivered.empty?
      }.from(false).to true
    end
  end
  
  describe '#normalize_frequency' do
    subject{ mailer.normalize_frequency frequency }
    
    context 'with immediate' do
      let(:frequency){ :immediate }
      it{ is_expected.to eql 0 }
    end
    
    context 'with daily' do
      let(:frequency){ :daily }
      it{ is_expected.to eql 1 }
    end
    
    context 'with weekly' do
      let(:frequency){ :weekly }
      it{ is_expected.to eql 2 }
    end
    
    context 'with an integer' do
      let(:frequency){ 1 }
      it{ is_expected.to eql 1 }
    end
  end
  
  describe '#digest_label_for' do
    subject{ mailer.digest_label_for frequency }
    
    context 'with immediate' do
      let(:frequency){ :immediate }
      it{ is_expected.to be_blank }
    end
    
    context 'with daily' do
      let(:frequency){ :daily }
      it{ is_expected.to eql 'Daily Digest of ' }
    end
    
    context 'with weekly' do
      let(:frequency){ :weekly }
      it{ is_expected.to eql 'Weekly Digest of ' }
    end
  end
  
  describe '#subject' do
    subject{ mailer.subject :immediate }
    it{ is_expected.to eql 'Zooniverse Talk Notifications' }
  end
end
