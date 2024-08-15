require 'spec_helper'

RSpec.shared_context 'a serializer' do
  let(:serializer){ described_class }
  let(:model){ serializer.model_class }
  let(:instance){ FactoryBot.create serializer.singular_key }
  let(:model_instance){ instance }
  let(:serializer_context){ { } }
  let(:json){ serializer.as_json model_instance, serializer_context }
end

RSpec.shared_examples_for 'a talk serializer' do |exposing: nil, excluding: [], including: nil|
  [exposing, excluding, including].compact.each{ |opt| opt.map!(&:to_sym) if opt.is_a?(Array) }
  include_context 'a serializer'
  let(:model_instance){ defined?(object) ? object : instance }

  describe 'attributes' do
    subject{ json }

    if exposing == :all
      described_class.model_class.attribute_names.each do |name|
        it{ is_expected.to include name.to_sym } unless name.to_sym.in?(excluding)
      end
    elsif exposing
      exposing.each do |name|
        it{ is_expected.to include name.to_sym }
      end
    end

    excluding.each do |name|
      it{ is_expected.to_not include name.to_sym }
    end

    it{ is_expected.to include :href }
  end

  describe 'meta' do
    let(:sortable_attributes){ serializer.serializable_sorting_attributes || [] }
    let(:sortable_attribute){ sortable_attributes.sample.to_s }
    subject{ serializer.page({ sort: sortable_attribute })[:meta][serializer.model_class.table_name.to_sym] }

    its([:current_sort]){ is_expected.to eql sortable_attribute }
    its([:default_sort]){ is_expected.to eql serializer.default_sort }
    its([:sortable_attributes]){ is_expected.to match_array sortable_attributes }
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
