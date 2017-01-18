module BooleanCoercion
  extend ActiveSupport::Concern

  included do
    columns_hash.each_pair do |attribute, adapter|
      next unless adapter.type == :boolean
      define_method "#{ attribute }=" do |value|
        super !!value
      end
    end if table_exists?
  end
end