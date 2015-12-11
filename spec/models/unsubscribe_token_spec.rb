require 'rspec'

RSpec.describe UnsubscribeToken, type: :model do
  it_behaves_like 'an expirable model' do
    let!(:fresh){ create_list :unsubscribe_token, 2 }
    let!(:stale){ create_list :unsubscribe_token, 2, expires_at: 1.year.ago.utc }
  end
  
  describe '.for_user' do
    let(:token){ create :unsubscribe_token }
    let(:other_user){ create :user }
    
    it 'should find existing' do
      expect(UnsubscribeToken.for_user(token.user)).to eql token
    end
    
    it 'should create when not existing' do
      expect(UnsubscribeToken).to receive(:create).and_call_original
      UnsubscribeToken.for_user other_user
    end
    
    it 'should handle collisions' do
      allow(SecureRandom).to receive(:hex).and_return(token.token, 'something else')
      expect(UnsubscribeToken.for_user(other_user).token).to eql 'something else'
    end
    
    it 'should reset expires_at' do
      first = 1.week.ago.utc
      token.update_attribute :expires_at, first
      
      expect {
        UnsubscribeToken.for_user(token.user)
      }.to change {
        token.reload.expires_at
      }.from(first).to be_within(1.second).of(1.month.from_now.utc)
    end
  end
  
  describe '#set_expiration' do
    subject{ create :unsubscribe_token }
    its(:expires_at){ is_expected.to be_within(1.second).of 1.month.from_now }
  end
  
  describe '#set_token!' do
    it 'should assign on creation' do
      token = build :unsubscribe_token
      expect(token).to receive(:set_token!).and_call_original
      token.save
    end
    
    it 'should handle collisions' do
      token1 = create :unsubscribe_token
      token2 = create :unsubscribe_token
      allow(SecureRandom).to receive(:hex).and_return token1.token, 'something else'
      
      expect{
        token2.set_token!
      }.to change{
        token2.token
      }.to 'something else'
    end
  end
end
