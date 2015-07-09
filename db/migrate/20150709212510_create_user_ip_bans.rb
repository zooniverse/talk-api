class CreateUserIpBans < ActiveRecord::Migration
  def change
    create_table :user_ip_bans do |t|
      t.cidr :ip, null: false
      t.timestamps
    end
    
    add_index :user_ip_bans, :ip
  end
end
