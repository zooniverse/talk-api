require 'spec_helper'

RSpec.describe BoardPolicy, type: :policy do
  let(:user){ }
  let(:record){ create :board, section: 'test' }
  let(:subject){ BoardPolicy.new user, record }
  
  context 'without a user' do
    it_behaves_like 'a policy permitting', :index, :show
    it_behaves_like 'a policy forbidding', :create, :update, :destroy
  end
  
  context 'with a user' do
    let(:user){ create :user }
    it_behaves_like 'a policy permitting', :index, :show
    it_behaves_like 'a policy forbidding', :create, :update, :destroy
  end
  
  context 'with a moderator' do
    let(:user){ create :moderator }
    it_behaves_like 'a policy permitting', :index, :show, :create, :update, :destroy
  end
  
  context 'with an admin' do
    let(:user){ create :admin }
    it_behaves_like 'a policy permitting', :index, :show, :create, :update, :destroy
  end
  
  context 'with scope' do
    let!(:public_boards){ create_list :board, 2, section: '1-project' }
    let!(:team_boards){ create_list :board, 2, section: '1-project', permissions: { read: 'team', write: 'team' } }
    let!(:admin_boards){ create_list :board, 2, section: '1-project', permissions: { read: 'admin', write: 'admin' } }
    let!(:moderator_boards){ create_list :board, 2, section: '1-project', permissions: { read: 'moderator', write: 'moderator' } }
    let!(:other_boards){ create_list :board, 2, section: '2-project', permissions: { read: 'admin', write: 'admin' } }
    let(:subject){ BoardPolicy::Scope.new(user, Board).resolve }
    
    context 'without a user' do
      it{ is_expected.to match_array public_boards }
    end
    
    context 'with a scientist' do
      let(:user){ create :scientist, section: '1-project' }
      it{ is_expected.to match_array public_boards + team_boards }
    end
    
    context 'with a moderator' do
      let(:user){ create :moderator, section: '1-project' }
      it{ is_expected.to match_array public_boards + team_boards + moderator_boards }
    end
    
    context 'with an admin' do
      let(:user){ create :admin, section: '1-project' }
      it{ is_expected.to match_array public_boards + team_boards + moderator_boards + admin_boards }
    end
    
    context 'with a zooniverse admin' do
      let(:user){ create :admin, section: 'zooniverse' }
      it{ is_expected.to match_array public_boards + team_boards + moderator_boards + admin_boards + other_boards }
    end
  end
end
