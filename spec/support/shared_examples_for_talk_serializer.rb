require 'spec_helper'

RSpec.shared_context 'a serializer' do
  let(:serializer){ described_class }
  let(:model){ serializer.model_class }
  let(:instance){ FactoryGirl.create serializer.singular_key }
  let(:model_instance){ instance }
  let(:json){ serializer.as_json model_instance }
end

RSpec.shared_examples_for 'a talk serializer' do |exposing: nil, including: nil|
  include_context 'a serializer'
  let(:model_instance){ defined?(object) ? object : instance }
  
  describe 'attributes' do
    subject{ json }
    
    if exposing == :all
      described_class.model_class.attribute_names.each do |name|
        it{ is_expected.to include name.to_sym }
      end
    elsif exposing
      exposing.each do |name|
        it{ is_expected.to include name.to_sym }
      end
    end
    
    it{ is_expected.to include :href }
  end
  
  describe 'associations' do
    if including
      including.each do |association|
        it "should allow inclusion of #{ association }" do
          association = association.to_s
          json = serializer.resource id: model_instance.id, include: association
          association_key = association.to_s.pluralize.to_sym
          expect(json[:linked]).to include association_key
          
          macro = model.reflect_on_association(association).macro
          unless macro.in? [:belongs_to, :has_one]
            expect(json[:meta]).to include association_key
          end
        end
      end
    end
  end
end
