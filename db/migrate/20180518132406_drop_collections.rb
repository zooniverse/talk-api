class DropCollections < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute <<-SQL
      do language plpgsql $$
        begin
          create or replace view searches as
            select * from searchable_boards
            union all
            select * from searchable_comments
            union all
            select * from searchable_discussions;
        end;
      $$;
      DROP MATERIALIZED VIEW IF EXISTS searchable_collections;

      DROP FOREIGN TABLE IF EXISTS collections;
      DROP FOREIGN TABLE IF EXISTS collection_subjects;
      DROP SEQUENCE IF EXISTS collections_id_seq;
      DROP SEQUENCE IF EXISTS collection_subjects_id_seq;
SQL
  end
end
