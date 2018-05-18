class DropCollections < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute <<-SQL
      DROP FOREIGN TABLE IF EXISTS collections;
      DROP FOREIGN TABLE IF EXISTS collection_subjects;
      DROP SEQUENCE IF EXISTS collections_id_seq;
      DROP SEQUENCE IF EXISTS collection_subjects_id_seq;
SQL
  end
end
