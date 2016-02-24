require 'spec_helper'

RSpec.describe AnnouncementSchema, type: :schema do
  shared_examples_for 'an announcement schema' do
    its(:type){ is_expected.to eql 'object' }
    its(:required){ is_expected.to eql ['announcements'] }

    with 'properties .announcements' do
      its(:type){ is_expected.to eql 'object' }
      its(:additionalProperties){ is_expected.to be false }

      with :properties do
        its(:message){ is_expected.to eql type: 'string' }
        its(:section){ is_expected.to eql type: 'string' }
        its(:expires_at){ is_expected.to eql type: 'string' }
      end
    end
  end

  describe '#create' do
    let(:schema_method){ :create }
    it_behaves_like 'an announcement schema'

    with 'properties .announcements' do
      its(:required){ is_expected.to eql %w(message section) }
    end
  end

  describe '#update' do
    let(:schema_method){ :update }
    it_behaves_like 'an announcement schema'

    with 'properties .announcements' do
      its(:required){ is_expected.to be_nil }
    end
  end
end
