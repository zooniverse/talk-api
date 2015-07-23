require 'spec_helper'

RSpec.shared_examples_for 'an expirable model' do
  let(:fresh){ [] }
  let(:stale){ [] }
  
  describe '.expired' do
    it 'should find expired records' do
      expect(described_class.expired).to match_array stale
    end
    
    it 'should not include unexpired records' do
      expect(described_class.expired).to_not include fresh
    end
  end
end
