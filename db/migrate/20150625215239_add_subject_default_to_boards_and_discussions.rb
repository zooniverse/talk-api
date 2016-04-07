class AddSubjectDefaultToBoardsAndDiscussions < ActiveRecord::Migration
  def change
    add_column :boards, :subject_default, :boolean, null: false, default: false
    add_column :discussions, :subject_default, :boolean, null: false, default: false

    add_index :boards, [:section, :subject_default], unique: true, where: 'subject_default = true'
    add_index :discussions, [:board_id, :title, :subject_default], unique: true, where: 'subject_default = true'
  end
end
