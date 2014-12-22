require 'spec_helper'

RSpec.describe Focus, type: :model do
  it_behaves_like 'moderatable'
  
  context 'validating' do
    it 'should require a section' do
      without_section = build :focus, section: nil
      expect(without_section).to fail_validation section: "can't be blank"
    end
  end
end
