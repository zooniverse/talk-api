require 'spec_helper'

RSpec.shared_examples_for 'a focus schema' do
  its(:focus_id){ is_expected.to eql nullable_id_schema }
  its(:focus_type){ is_expected.to eql enum: %w(Subject Collection) }
end
