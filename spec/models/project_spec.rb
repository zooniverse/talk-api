require 'spec_helper'

RSpec.describe Project, type: :model do
  it_behaves_like 'a subscribable model'
  
  describe '.from_section' do
    let!(:project){ create :project }
    let(:valid_section){ "project-#{ project.id }" }
    let(:invalid_section){ 'nope' }
    
    it 'should find projects' do
      expect(Project.from_section(valid_section)).to eql project
    end
    
    it 'should handle invalid sections' do
      expect(Project.from_section(invalid_section)).to eql nil
    end
  end
  
  describe '#create_system_notification' do
    let(:user){ create :user }
    let(:unsubscribed_user){ create :user }
    let(:project){ create :project }
    
    before :each do
      unsubscribed_user.preference_for(:system).update_attributes enabled: false
    end
    
    def notify(notified_user)
      project.create_system_notification notified_user, url: 'foo', message: 'bar'
    end
    
    context 'with a subscribed user' do
      subject{ notify user }
      
      it{ is_expected.to be_a Notification }
      its(:user){ is_expected.to eql user }
      its(:section){ is_expected.to eql "project-#{ project.id }" }
      
      context 'with a subscription' do
        subject{ notify(user).subscription }
        
        it{ is_expected.to be_system }
        its(:source){ is_expected.to eql project }
      end
    end
    
    context 'without a subscribed user' do
      subject{ notify unsubscribed_user }
      it{ is_expected.to be nil }
    end
  end
end
