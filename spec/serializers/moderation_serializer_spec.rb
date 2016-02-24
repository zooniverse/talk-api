require 'spec_helper'

RSpec.describe ModerationSerializer, type: :serializer do
  it_behaves_like 'a talk serializer', exposing: :all do
    let(:target){ create :comment }
    let(:model_instance){ create :moderation, target: target }
    let(:current_user){ create :admin, section: target.section }
    let(:serializer_context){ { current_user: current_user } }

    context 'with a target' do
      subject{ json }
      it{ is_expected.to include :target }
      its([:target]){ is_expected.to include :id => target.id.to_s }

      context 'with moderatable_actions' do
        subject{ json[:target][:moderatable_actions] }
        it{ is_expected.to match_array target.class.moderatable.keys }
      end
    end

    context 'without a target' do
      before(:each) do
        model_instance.update! actions: [{ user_id: 1, action: 'destroy', message: 'foo' }]
        model_instance.reload
      end

      subject{ json }
      its([:target]){ is_expected.to_not be_present }
      its([:target_id]){ is_expected.to_not be_present }
      its([:target_type]){ is_expected.to be_nil }
    end
  end
end
