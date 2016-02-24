require 'spec_helper'

RSpec::Matchers.define :fail_validation do |attrs_and_messages|
  matching_errors = { }

  match do |record|
    is_valid = record.valid?
    return !is_valid unless attrs_and_messages.present?

    attrs_and_messages.each_pair do |attr, message|
      errors = record.errors[attr] || []
      matches = errors.select{ |m| m[message] }
      matching_errors[attr] = matches.length > 0
    end

    unmatched_error = matching_errors.values.include? false
    !is_valid && !unmatched_error
  end

  failure_message do |record|
    message = ''

    matching_errors.each_pair do |attr, matches|
      next if matches
      message += "expected #{ record.class } to fail validation for #{ attr }"
      message += " with #{ attrs_and_messages[attr] }" if message
      message += "\nerrors were #{ actual.errors.messages[attr].inspect }\n"
    end

    message
  end
end
