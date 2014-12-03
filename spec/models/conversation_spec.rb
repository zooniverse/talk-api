require 'spec_helper'

RSpec.describe Conversation, type: :model do
  it_behaves_like 'moderatable'
  
  context 'validating' do
    it 'should require a title' do
      without_title = build :conversation, title: nil
      expect(without_title).to fail_validation title: "can't be blank"
    end
    
    it 'should limit title length' do
      short_title = build :conversation, title: 'a'
      expect(short_title).to fail_validation title: 'too short'
      long_title = build :conversation, title: '!' * 200
      expect(long_title).to fail_validation title: 'too long'
    end
  end
end
