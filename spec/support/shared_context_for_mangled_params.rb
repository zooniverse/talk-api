require 'spec_helper'

RSpec.shared_context 'mangled params' do
  let(:awful_strings){ JSON.parse File.read Rails.root.join 'spec/support/awful_strings.json' }
  
  def mangle(object)
    case object
    when Hash
      object.dup.tap do |mangled|
        object.each_pair do |key, value|
          mangled[key] = mangle value
        end
      end
    when Array
      object.map{ |item| mangle item }
    else
      rand < 0.5 ? object : awful_strings.sample
    end
  end
end
