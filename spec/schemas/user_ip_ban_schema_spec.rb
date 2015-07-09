require 'spec_helper'

RSpec.describe UserIpBanSchema, type: :schema do
  describe '#create' do
    let(:schema_method){ :create }
    its(:type){ is_expected.to eql 'object' }
    its(:required){ is_expected.to eql ['user_ip_bans'] }
    
    with 'properties .user_ip_bans' do
      its(:type){ is_expected.to eql 'object' }
      its(:required){ is_expected.to eql %w(ip) }
      its(:additionalProperties){ is_expected.to be false }
      
      with :properties do
        its(:ip){ is_expected.to eql type: 'string' }
      end
    end
  end
end
