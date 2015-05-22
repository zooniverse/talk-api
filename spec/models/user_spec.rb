require 'spec_helper'

RSpec.describe User, type: :model do
  it_behaves_like 'moderatable'
  
  describe '#mentioned_by' do
    let(:user){ create :user }
    let(:comment){ create :comment }
    
    it 'should create a notification' do
      expect(Notification).to receive :create
      subject.mentioned_by comment
    end
    
    context 'notification' do
      subject{ user.mentioned_by comment }
      its(:user_id){ is_expected.to eql user.id }
      its(:message){ is_expected.to eql "You were mentioned by #{ comment.user_display_name }" }
      its(:url){ is_expected.to eql "http://localhost:3000/comments/#{ comment.id }" }
      its(:section){ is_expected.to eql comment.section }
    end
  end
end
