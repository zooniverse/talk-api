class AddMultipleSectionsToSearchables < ActiveRecord::Migration
  def self.up
    %w(boards comments discussions).each do |kind|
      table_name = :"searchable_#{ kind }"
      remove_index table_name, [:section, :searchable_type]
      rename_column table_name, :section, :sections
      change_column table_name, :sections, "varchar[] using(string_to_array(sections, ','))"
      change_column_default table_name, :sections, []
      add_index table_name, [:sections, :searchable_type]
    end
  end
  
  def self.down
    %w(boards comments discussions).each do |kind|
      table_name = :"searchable_#{ kind }"
      remove_index table_name, [:sections, :searchable_type]
      rename_column table_name, :sections, :section
      change_column table_name, :section, "varchar using(array_to_string(section, ','))"
      change_column_default table_name, :section, nil
      add_index table_name, [:section, :searchable_type]
    end
  end
end
