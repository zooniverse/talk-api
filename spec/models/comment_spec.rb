require 'spec_helper'

RSpec.describe Comment, type: :model do
  context 'validating' do
    it 'should require a body' do
      without_body = build :comment, body: nil
      expect(without_body).to fail_validation body: "can't be blank"
    end
    
    it 'should require a user' do
      without_user = build :comment, user_id: nil
      expect(without_user).to fail_validation user: "can't be blank"
    end
  end
  
  context 'creating' do
    it 'should set default attributes' do
      comment = create :comment
      expect(comment.tags).to eq({ })
      expect(comment.is_deleted).to be false
    end
    
    it 'should denormalize the user name' do
      comment = create :comment
      expect(comment.user_name).to eq comment.user.name
    end
    
    it 'should denormalize the focus type for focus subclasses' do
      subject_comment = create :comment, focus: build(:subject)
      expect(subject_comment.focus_type).to eql 'Subject'
    end
    
    it 'should not denormalize the focus type for the focus base class' do
      focus_comment = create :comment, focus: build(:focus)
      expect(focus_comment.focus_type).to be_nil
    end
  end
end
