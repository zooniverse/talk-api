require 'spec_helper'

RSpec.describe ApplicationService, type: :service do
  describe '.inherited' do
    before(:each){ ApplicationService.inherited subject }
    subject do
      Class.new do
        cattr_accessor :model_class, :schema_class
        def self.name; 'CommentService'; end
      end
    end

    its(:model_class){ is_expected.to eql Comment }
    its(:schema_class){ is_expected.to eql CommentSchema }
  end
end
