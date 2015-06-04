require 'spec_helper'

RSpec::Matchers.define :permit do |action|
  match do |policy|
    policy.public_send "#{ action }?"
  end
  
  failure_message do |policy|
    "#{ policy.class } does not permit #{ action } on #{ policy.record } for #{ policy.user.inspect }."
  end
  
  failure_message_when_negated do |policy|
    "#{ policy.class } does not forbid #{ action } on #{ policy.record } for #{ policy.user.inspect }."
  end
end

RSpec::Matchers.define :exclude_scope do
  match do |policy|
    policy.scope.resolve.empty?
  end
  
  failure_message do |policy|
    "#{ policy.class } does not exclude #{ policy.record } for #{ policy.user.inspect }."
  end
  
  failure_message_when_negated do |policy|
    "#{ policy.class } excludes #{ policy.record } for #{ policy.user.inspect }."
  end
end
