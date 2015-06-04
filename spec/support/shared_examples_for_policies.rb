require 'spec_helper'

RSpec.shared_examples_for 'a policy permitting' do |*actions|
  actions.each do |action|
    it{ is_expected.to permit action }
  end
end

RSpec.shared_examples_for 'a policy forbidding' do |*actions|
  actions.each do |action|
    it{ is_expected.to_not permit action }
  end
end

RSpec.shared_examples_for 'a policy excluding' do |*actions|
  actions.each do |action|
    it{ is_expected.to exclude_scope action }
  end
end
