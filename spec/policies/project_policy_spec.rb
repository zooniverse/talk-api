require 'spec_helper'

RSpec.describe ProjectPolicy, type: :policy do
  let(:user){ }
  let(:record){ create :project }
  subject{ ProjectPolicy.new user, record }

  context 'with a public project' do
    it_behaves_like 'a policy permitting', :index, :show
    it_behaves_like 'a policy forbidding', :create, :update, :destroy
  end

  context 'with a private project' do
    let(:record){ create :project, private: true }
    it_behaves_like 'a policy permitting', :index
    it_behaves_like 'a policy forbidding', :show, :create, :update, :destroy
  end

  context 'with scope' do
    let!(:launched1){ create :project, launched_row_order: 1 }
    let!(:board1){ create :board, section: "project-#{ launched1.id }" }
    let!(:second_board_of_launched1){ create :board, section: "project-#{ launched1.id }" }

    let!(:launched2){ create :project, launched_row_order: 2 }
    let!(:board2){ create :board, section: "project-#{ launched2.id }" }

    let!(:launched3){ create :project }

    let!(:launched_private1){ create :project, private: true }
    let!(:board3){ create :board, section: "project-#{ launched_private1.id }"}

    let!(:launched_private2){ create :project, private: true }

    let!(:unlaunched1){ create :project, launch_approved: false }
    let!(:board4){ create :board, section: "project-#{ unlaunched1.id }" }

    let!(:unlaunched2){ create :project, launch_approved: false }

    let!(:unlaunched_private1){ create :project, launch_approved: false }
    let!(:board5){ create :board, section: "project-#{ unlaunched_private1.id }" }

    let!(:unlaunched_private2){ create :project, launch_approved: false }

    subject{ ProjectPolicy::Scope.new(user, Project).resolve.to_a }

    it{ is_expected.to eql [launched2, launched1] }
  end
end
