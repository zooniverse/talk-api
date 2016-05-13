require 'spec_helper'

RSpec.describe UsernameCompletion, type: :lib do
  let(:searching_user){ create :user }
  let(:search){ '' }
  let(:limit){ 10 }

  let(:results){ UsernameCompletion.new(searching_user, search, limit: limit).results }
  subject{ results.map{ |h| h['login'] } }

  before :each do
    messaged_user = create :user, login: 'messaged', display_name: 'Foo'
    create :conversation_with_messages, user: searching_user, recipients: [messaged_user]

    mentioned_user = create :user, login: 'mentioned', display_name: 'Bar'
    create :comment, body: '@mentioned', user: searching_user

    create :user, login: 'michael', display_name: 'Baz'
    create :user, login: 'a_user', display_name: 'User'
  end

  context 'when matching login' do
    let(:search){ 'm' }
    it{ is_expected.to eql %w(messaged mentioned moderators michael) }
  end

  context 'when matching display_name' do
    let(:search){ 'b' }
    it{ is_expected.to eql %w(mentioned michael) }
  end

  context 'when limiting results' do
    let(:limit){ 1 }
    let(:search){ 'm' }
    it{ is_expected.to eql ['messaged'] }
  end

  context 'when sanitizing input' do
    let(:prioritized_users) do
      %w(messaged mentioned admins moderators researchers scientists team)
    end

    context 'when the pattern is empty' do
      let(:search){ '%' }
      it{ is_expected.to all be_in prioritized_users }
    end

    context 'when the pattern is nil' do
      let(:search){ nil }
      it{ is_expected.to all be_in prioritized_users }
    end

    context 'when the pattern is invalid' do
      let(:search){ '#.\'\\\\)\'' }
      it{ is_expected.to all be_in prioritized_users }
    end
  end
end
