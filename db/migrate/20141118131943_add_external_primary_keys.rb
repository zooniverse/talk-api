class AddExternalPrimaryKeys < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE users ADD PRIMARY KEY (id);
      ALTER TABLE focuses ADD PRIMARY KEY (id);
    SQL
  end
    
  def down
    execute <<-SQL
      ALTER TABLE users DROP CONSTRAINT users_pkey;
      ALTER TABLE focuses DROP CONSTRAINT focuses_pkey;
    SQL
  end
end
