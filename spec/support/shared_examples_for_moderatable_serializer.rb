require 'spec_helper'

RSpec.shared_examples_for 'a moderatable serializer' do
  let(:model_klass){ described_class.model_class }
  let(:record){ create model_klass }
  let(:resource){ described_class.resource({ id: record.id }, nil, current_user: current_user) }
  let(:current_user){ }

  let(:not_logged_in_actions){ [] }
  let(:logged_in_actions){ [] }
  let(:moderator_actions){ [] }
  let(:admin_actions){ [] }

  subject{ resource[model_klass.table_name.to_sym].first }

  context 'without a user' do
    its([:moderatable_actions]){ is_expected.to match_array not_logged_in_actions }
  end

  context 'with a user' do
    let(:current_user){ create :user }
    its([:moderatable_actions]){ is_expected.to match_array logged_in_actions }
  end

  context 'with a moderator' do
    let(:current_user){ create :moderator, section: 'zooniverse' }
    its([:moderatable_actions]){ is_expected.to match_array moderator_actions }
  end

  context 'with an admin' do
    let(:current_user){ create :admin, section: 'zooniverse' }
    its([:moderatable_actions]){ is_expected.to match_array admin_actions }
  end
end
