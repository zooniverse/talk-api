require 'spec_helper'

RSpec.describe DiscussionSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all, including: [:comments, :board, :user] do
    subject{ json }
    its([:user_display_name]){ is_expected.to eql model_instance.user.display_name }
    
    describe '.default_sort' do
      let(:board){ create :board }
      let!(:discussion1){ create :discussion, board: board, updated_at: 1.minute.ago.utc }
      let!(:discussion2){ create :discussion, board: board, updated_at: 2.minutes.ago.utc }
      let!(:sticky1){ create :discussion, board: board, updated_at: 2.minute.ago.utc, sticky: true, sticky_position: 1 }
      let!(:sticky2){ create :discussion, board: board, updated_at: 1.minutes.ago.utc, sticky: true, sticky_position: 2 }
      let(:policy_scope){ DiscussionPolicy::Scope.new nil, model.all }
      let(:json){ serializer.page({ sort: serializer.default_sort }, policy_scope.resolve) }
      subject{ json[:discussions].collect{ |d| d[:id] } }
      
      it{ is_expected.to eql [sticky1.id, sticky2.id, discussion1.id, discussion2.id].collect(&:to_s) }
    end
  end
  
  it_behaves_like 'a moderatable serializer' do
    let(:not_logged_in_actions){ [] }
    let(:logged_in_actions){ [:report] }
    let(:moderator_actions){ [:report, :watch, :destroy, :ignore] }
    let(:admin_actions){ [:report, :watch, :destroy, :ignore] }
  end
end
