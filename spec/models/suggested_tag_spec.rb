require 'spec_helper'

RSpec.describe SuggestedTag, type: :model do
  context 'validating' do
    it 'should require a name' do
      without_name = build :suggested_tag, name: nil
      expect(without_name).to fail_validation name: "can't be blank"
    end

    it 'should require a section' do
      without_section = build :suggested_tag, section: nil
      expect(without_section).to fail_validation section: "can't be blank"
    end

    it 'should enforce a minimum name length' do
      too_short = build :suggested_tag, name: 'a'
      expect(too_short).to fail_validation name: 'is too short (minimum is 3 characters)'
    end

    it 'should enforce a maximum name length' do
      too_short = build :suggested_tag, name: 'a' * 50
      expect(too_short).to fail_validation name: 'is too long (maximum is 40 characters)'
    end

    it 'should prevent duplicates' do
      suggested_tag = create :suggested_tag
      duplicate = build :suggested_tag, section: suggested_tag.section, name: suggested_tag.name
      expect(duplicate).to fail_validation name: 'Suggested tag already exists for this section'
    end
  end

  describe '#normalize_name' do
    let(:suggested_tag){ create :suggested_tag, name: '#FOO!))   ' }

    it 'should format name on create' do
      expect(suggested_tag.name).to eql 'foo'
    end

    it 'should format name on update' do
      suggested_tag.update! name: '#FOO_Bar,,   ... '
      expect(suggested_tag.name).to eql 'foo_bar'
    end
  end
end
