class CreateSearchIndexes < ActiveRecord::Migration
  def up
    execute <<-SQL
      create index search_index on searches using gin(
        setweight(to_tsvector('english', tags), 'A'),
        setweight(to_tsvector('english', content), 'B')
      );
      
      create index search_section_index on searches using btree(section);
    SQL
  end
  
  def down
    execute <<-SQL
      drop index search_index;
      drop index search_section_index;
    SQL
  end
end
