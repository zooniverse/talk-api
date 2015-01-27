module ActiveRecord::ConnectionAdapters::SchemaStatements
  def change_column_with_cast(table_name, column_name, new_type, default: nil)
    change_column_default(table_name, column_name, nil) if default
    change_column table_name, column_name, "#{ new_type } USING #{ column_name }::#{ new_type }"
    change_column_default(table_name, column_name, default) if default
  end
end
