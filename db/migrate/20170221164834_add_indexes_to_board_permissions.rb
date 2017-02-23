class AddIndexesToBoardPermissions < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    indexes.each do |name, perms|
      unless index_exists?(:boards, nil, name: name)
        add_index :boards,
          name: name,
          expression: "(permissions->>'#{perms}')",
          algorithm: :concurrently
      end
    end
  end

  def down
    indexes.keys.each do |name|
      remove_index(:boards, name: name) if index_exists?(:boards, nil, name: name)
    end
  end

  private

  def indexes
    {
      "boards_read_permission_index" => 'read',
      "boards_write_permission_index" => 'write'
    }
  end
end
