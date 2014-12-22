require 'spec_helper'

RSpec.describe User, type: :model do
  it_behaves_like 'moderatable'
  it_behaves_like 'an api resource', attributes: [:id, :login, :display_name], updateable: [:display_name] do
    let(:api_record) do
      {
        'id' => '100',
        'login' => 'somebody',
        'display_name' => 'different'
      }
    end
  end
end
