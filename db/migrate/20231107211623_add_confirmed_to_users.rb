# frozen_string_literal: true

class AddConfirmedToUsers < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER FOREIGN TABLE users ADD COLUMN confirmed_at TIMESTAMP DEFAULT NULL
    SQL
  end

  def down
    execute <<-SQL
      ALTER FOREIGN TABLE users DROP COLUMN IF EXISTS confirmed_at;
    SQL
  end
end
