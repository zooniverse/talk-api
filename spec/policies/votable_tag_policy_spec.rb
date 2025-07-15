# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VotableTagPolicy, type: :policy do
  let!(:record) { create :votable_tag }
  subject { VotableTagPolicy.new user, record }
  let(:user) {}

  context 'without a user' do
    it_behaves_like 'a policy permitting', :index, :show
    it_behaves_like 'a policy forbidding', :create, :update, :destroy
  end

  context 'with a user' do
    let(:user) { create :user }
    it_behaves_like 'a policy permitting', :index, :show, :create
    it_behaves_like 'a policy forbidding', :update, :destroy
  end

  context 'with scope' do
    let!(:deleted_votable_tag) { create :votable_tag, is_deleted: true }
    subject { VotableTagPolicy::Scope.new(user, VotableTag).resolve.to_a }
    it { is_expected.to include(record) }
    it { is_expected.not_to include(deleted_votable_tag) }
  end
end
