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
  end
end
