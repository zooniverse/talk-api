require 'spec_helper'

RSpec.describe TagCompletion, type: :lib do
  let(:search){ '' }
  let(:section){ 'project-1' }
  let(:limit){ 10 }

  let(:results){ TagCompletion.new(search, section, limit: limit).results }
  subject{ results.map{ |h| h['name'] } }

  before :each do
    create_list :tag, 3, name: 'foo'
    tags = create_list :tag, 2, name: 'foobar'
    duplicate_tag = create :tag, name: 'foobar', user: tags.first.user
    create :tag, name: 'bar'
    create :tag, name: 'other', taggable_section: 'other'
  end

  context 'when partially matching tags' do
    let(:search){ 'f' }

    it{ is_expected.to match_array %w(foo foobar) }
    it{ is_expected.to_not include 'other' }
    its(:first){ is_expected.to eql 'foo' }
  end

  context 'when completely matching tags' do
    let(:search){ 'foobar' }

    it{ is_expected.to match_array %w(foo foobar bar) }
    it{ is_expected.to_not include 'other' }
    its(:first){ is_expected.to eql 'foobar' }
    its(:second){ is_expected.to eql 'foo' }
  end

  context 'when filtering sections' do
    let(:section){ 'other' }
    let(:search){ 'o' }

    it{ is_expected.to eql ['other'] }
  end

  context 'when limiting results' do
    let(:search){ 'f' }
    let(:limit){ 1 }
    it{ is_expected.to eql ['foo'] }
  end

  context 'when sanitizing input' do
    context 'when the pattern is empty' do
      let(:search){ '# ' }
      it{ is_expected.to be_empty }
    end

    context 'when the pattern is nil' do
      let(:search){ nil }
      it{ is_expected.to be_empty }
    end

    context 'when the pattern is invalid' do
      let(:search){ '#.\'\\\\)\'' }
      it{ is_expected.to be_empty }
    end
  end
end
