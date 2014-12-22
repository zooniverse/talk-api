require 'spec_helper'

RSpec.describe Tag, type: :model do
  context 'validating' do
    it 'should require a section' do
      without_section = build :tag, section: nil
      expect(without_section).to fail_validation section: "can't be blank"
    end
  end
end
