# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TagVoteSchema, type: :schema do
  describe '#create' do
    let(:schema_method) { :create }
    its(:type) { is_expected.to eql 'object' }
    its(:required) { is_expected.to eql ['tag_votes'] }

    with 'properties .tag_votes' do
      its(:type) { is_expected.to eql 'object' }
      its(:required) { is_expected.to eql %w[user_id votable_tag_id] }
      its(:additionalProperties) { is_expected.to be false }

      with :properties do
        its(:user_id) { is_expected.to eql id_schema }
        its(:votable_tag_id) { is_expected.to eql id_schema }
      end
    end
  end
end
