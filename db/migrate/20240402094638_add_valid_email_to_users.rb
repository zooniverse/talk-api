class AddValidEmailToUsers < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER FOREIGN TABLE users ADD COLUMN valid_email boolean DEFAULT true;
    SQL
  end

  def down
    execute <<-SQL
      ALTER FOREIGN TABLE users DROP COLUMN IF EXISTS valid_email;
    SQL
  end
end
