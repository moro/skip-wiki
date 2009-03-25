class AddDeletedFlagToPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :deleted, :boolean, :default => false
    add_index  :pages, [:deleted, :note_id]
    add_index  :pages, [:deleted, :name]
  end

  def self.down
    remove_index  :pages, [:deleted, :note_id]
    remove_index  :pages, [:deleted, :name]

    remove_column :pages, :deleted
  end
end
