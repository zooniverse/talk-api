# frozen_string_literal: true

require 'spec_helper'

RSpec.describe VotableTagSchema, type: :schema do
  describe '#create' do
    let(:schema_method) { :create }
    its(:type) { is_expected.to eql 'object' }
    its(:required) { is_expected.to eql ['votable_tags'] }

    with 'properties .votable_tags' do
      its(:type) { is_expected.to eql 'object' }
      its(:required) { is_expected.to eql %w[name section created_by_user_id] }
      its(:additionalProperties) { is_expected.to be false }

      with :properties do
        its(:name) { is_expected.to eql type: 'string' }
        its(:section) { is_expected.to eql type: 'string' }
        its(:created_by_user_id) { is_expected.to eql id_schema }
        its(:taggable_id) { is_expected.to eql nullable_id_schema }
        its(:taggable_type) { is_expected.to eql anyOf: [{ 'enum' => %w[Subject] }, { 'type' => 'null' }] }
      end
    end
  end
end
