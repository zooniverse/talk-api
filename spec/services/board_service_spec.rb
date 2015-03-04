require 'spec_helper'

RSpec.describe BoardService, type: :service do
  it_behaves_like 'a service', Board do
    let(:current_user){ create :moderator }
    let(:parent_board){ create :board }
    let(:create_params) do
      {
        boards: {
          title: 'works',
          description: 'works',
          section: 'test',
          parent_id: parent_board.id
        }
      }
    end
    
    it_behaves_like 'a service creating', Board
    it_behaves_like 'a service updating', Board do
      let(:update_params) do
        {
          id: record.id,
          boards: {
            title: 'new title',
            description: 'new description',
            parent_id: nil
          }
        }
      end
    end
  end
end
