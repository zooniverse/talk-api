require 'spec_helper'

RSpec.describe OauthAccessToken, type: :model do
  describe '#expired?' do
    let(:token){ create :oauth_access_token }
    let(:expired_token){ create :oauth_access_token, :expired }
    
    it 'should be true for expired tokens' do
      expect(expired_token).to be_expired
    end
    
    it 'should be false for valid tokens' do
      expect(token).to_not be_expired
    end
  end
  
  describe '#revoked?' do
    let(:token){ create :oauth_access_token }
    let(:revoked_token){ create :oauth_access_token, :revoked }
    
    it 'should be true for revoked tokens' do
      expect(revoked_token).to be_revoked
    end
    
    it 'should be false for valid tokens' do
      expect(token).to_not be_revoked
    end
  end
  
  describe '#resource_owner' do
    let(:token){ create :oauth_access_token }
    let(:expired_token){ create :oauth_access_token, :expired }
    let(:revoked_token){ create :oauth_access_token, :revoked }
    
    it 'should not raise anything with a valid token' do
      expect{ token.resource_owner }.to_not raise_error
    end
    
    it 'should raise if expired' do
      expect{ expired_token.resource_owner }.to raise_error OauthAccessToken::ExpiredError
    end
    
    it 'should raise if revoked' do
      expect{ revoked_token.resource_owner }.to raise_error OauthAccessToken::RevokedError
    end
  end
end
