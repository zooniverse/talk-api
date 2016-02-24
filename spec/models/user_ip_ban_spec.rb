require 'spec_helper'

RSpec.describe UserIpBan, type: :model do
  context 'validating' do
    it 'should require an ip' do
      without_ip = build :user_ip_ban, ip: nil
      expect(without_ip).to_not be_valid
      expect(without_ip).to fail_validation ip: "can't be blank"
    end
  end

  describe '.banned?' do
    let!(:specific_ban){ create :user_ip_ban, ip: '1.2.3.4/32' }
    let!(:subnet_ban){ create :user_ip_ban, ip: '2.3.4.5/24' }
    let(:specific_ip){ double remote_ip: '1.2.3.4' }
    let(:subnet_ip){ double remote_ip: '2.3.4.128' }
    let(:other_ip){ double remote_ip: '9.8.7.6' }
    subject{ UserIpBan.banned? ip }

    context 'with a specific ip' do
      let(:ip){ specific_ip }
      it{ is_expected.to be true }
    end

    context 'with a subnet ip' do
      let(:ip){ subnet_ip }
      it{ is_expected.to be true }
    end

    context 'with a non-banned ip' do
      let(:ip){ other_ip }
      it{ is_expected.to be false }
    end
  end
end
