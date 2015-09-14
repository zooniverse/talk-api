require 'spec_helper'

RSpec.describe GroupMention, type: :model do
  context 'validating' do
    it 'should require a comment' do
      without_comment = build :group_mention, comment: nil
      expect(without_comment).to fail_validation comment: "can't be blank"
    end
    
    it 'should require a section' do
      without_section = build :group_mention, section: nil
      allow(without_section).to receive :denormalize_attributes
      expect(without_section).to fail_validation section: "can't be blank"
    end
    
    it 'should require a name' do
      without_name = build :group_mention, name: nil
      expect(without_name).to fail_validation name: "can't be blank"
    end
    
    it 'should require a valid name' do
      without_name = build :group_mention, name: 'foo'
      expect(without_name).to fail_validation name: 'must be "admins", "moderators", "researchers", "scientists", or "team"'
    end
  end
  
  describe '#downcase_name' do
    subject{ create :group_mention, name: 'ADMINS' }
    its(:name){ is_expected.to eql 'admins' }
  end
  
  describe '#denormalize_attributes' do
    let(:comment){ create :comment }
    subject{ create :group_mention, comment: comment }
    its(:user){ is_expected.to eql comment.user }
    its(:section){ is_expected.to eql comment.section }
  end
  
  describe '#mentioned_users' do
    let(:moderators){ create_list :moderator, 2, section: 'project-1' }
    let(:researchers){ create_list :scientist, 2, section: 'project-1' }
    let(:group_mention){ create :group_mention, name: name, section: 'project-1' }
    subject{ group_mention.mentioned_users }
    
    context 'with moderators' do
      let(:name){ 'moderators' }
      it{ is_expected.to match_array moderators }
    end
    
    context 'with researchers' do
      let(:name){ 'researchers' }
      it{ is_expected.to match_array researchers }
    end
    
    context 'with scientists' do
      let(:name){ 'scientists' }
      it{ is_expected.to match_array researchers }
    end
    
    context 'with team' do
      let(:name){ 'team' }
      it{ is_expected.to match_array moderators + researchers }
    end
  end
  
  describe '#notify_later' do
    it 'should queue the notification' do
      group_mention = create :group_mention
      expect(GroupMentionWorker).to receive(:perform_async).with group_mention.id
      group_mention.run_callbacks :commit
    end
  end
  
  describe '#notify_mentioned' do
    let(:admins){ create_list :admin, 2, section: 'project-1' }
    let(:group_mention){ create :group_mention, name: 'admins', section: 'project-1' }
    before(:each){ allow(group_mention).to receive(:mentioned_users).and_return admins }
    
    it 'should notify of the mention' do
      admins.each do |admin|
        expect(admin).to receive(:group_mentioned_by).with group_mention
      end
      group_mention.notify_mentioned
    end
  end
end
