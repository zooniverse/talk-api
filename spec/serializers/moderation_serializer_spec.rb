require 'spec_helper'

RSpec.describe ModerationSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all do
    let(:target){ create :comment }
    let(:model_instance){ create :moderation, target: target }
    
    context 'with a target' do
      subject{ json }
      it{ is_expected.to include :target }
      its([:target]){ is_expected.to include :id => target.id }
    end
    
    context 'without a target' do
      before(:each) do
        model_instance.update! actions: [{ user_id: 1, action: 'destroy', message: 'foo' }]
        model_instance.reload
      end
      
      subject{ json }
      its([:target]){ is_expected.to_not be_present }
      its([:target_id]){ is_expected.to be_nil }
      its([:target_type]){ is_expected.to be_nil }
    end
  end
end
