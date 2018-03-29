require 'spec_helper'

RSpec.describe Tag, type: :model do
  it_behaves_like 'a sectioned model'

  describe '.in_section' do
    let!(:section_a){ create :tag, taggable_section: 'project-1' }
    let!(:section_b){ create :tag, taggable_section: 'project-2' }
    subject{ Tag.in_section 'project-1' }

    it{ is_expected.to include section_a }
    it{ is_expected.to_not include section_b }
  end

  describe '.of_type' do
    let(:subject_focus){ create :subject }
    let(:collection){ create :collection }
    let!(:subject_tag){ create :tag, taggable: subject_focus }
    let!(:collection_tag){ create :tag, taggable: collection }
    subject{ Tag.of_type 'subject' }

    it{ is_expected.to include subject_tag }
    it{ is_expected.to_not include collection_tag }
  end

  describe '.popular' do
    subject{ Tag.popular }
    before(:each) do
      focus = create :subject
      create_list :comment, 2, body: 'test #second', focus: focus
      create_list :comment, 3, body: 'test #first', focus: focus
      create_list :comment, 1, body: 'test #third'
    end

    it{ is_expected.to eql 'first' => 3, 'second' => 2, 'third' => 1 }
  end

  context 'validating' do
    it 'should require a section' do
      without_section = build :tag, section: nil, comment: nil
      expect(without_section).to fail_validation section: "can't be blank"
    end
  end

  describe '#propagate_values' do
    let(:comment){ create :comment_for_focus }
    subject{ Tag.new name: 'test', comment: comment }
    before(:each){ subject.valid? }

    its(:section){ is_expected.to eql comment.section }
    its(:user){ is_expected.to eql comment.user }
    its(:user_login){ is_expected.to eql comment.user.login }
    its(:taggable){ is_expected.to eql comment.focus }
    its(:taggable_type){ is_expected.to eql comment.focus.class.name }
  end
end
