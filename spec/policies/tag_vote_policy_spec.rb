require 'spec_helper'

RSpec.describe TagVotePolicy, type: :policy do
  let(:votable_tag) { create :votable_tag }
  let(:user) { create :user }
  let(:record) { create :tag_vote, user_id: user.id, votable_tag_id: votable_tag.id }
  subject { TagVotePolicy.new user, record }

  context 'without a user' do
    let(:no_user) {}
    subject { TagVotePolicy.new no_user, record }
    it_behaves_like 'a policy permitting', :index, :show
    it_behaves_like 'a policy forbidding', :create, :update, :destroy
  end

  context 'with a user' do
    it_behaves_like 'a policy permitting', :index, :show, :create, :destroy
    it_behaves_like 'a policy forbidding', :update

    context 'user does not own vote' do
      let(:other_user) { create :user }
      subject { TagVotePolicy.new other_user, record }
      it_behaves_like 'a policy forbidding', :create, :destroy
    end

    context 'votable_tag is soft destroyed' do
      let(:deleted_votable_tag) { create :votable_tag, is_deleted: true }
      let(:other_record) { create :tag_vote, votable_tag_id: deleted_votable_tag.id, user_id: user.id }
      subject { TagVotePolicy.new user, other_record }

      it_behaves_like 'a policy forbidding', :create
    end
  end
end
