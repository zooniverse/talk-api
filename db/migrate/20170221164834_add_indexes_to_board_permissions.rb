class AddIndexesToBoardPermissions < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    execute <<-SQL
      CREATE INDEX CONCURRENTLY boards_read_permission_index ON boards ((permissions->>'read'))
    SQL

    execute <<-SQL
      CREATE INDEX CONCURRENTLY boards_write_permission_index ON boards ((permissions->>'write'))
    SQL
  end

 def down
    execute <<-SQL
      DROP INDEX boards_read_permission_index
    SQL

    execute <<-SQL
      DROP INDEX boards_write_permission_index
    SQL
  end
end
