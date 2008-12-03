class SimplifyVersionable < ActiveRecord::Migration
  def self.up
    remove_index :histories, :name => "index_histories_on_versionables_and_rev"
    remove_column :histories, :versionable_type

    rename_column :histories, :versionable_id, :page_id
    add_index :histories, %w[page_id revision]
  end

  def self.down
    remove_index :histories, %w[page_id revision]
    rename_column :histories, :page_id, :versionable_id

    add_column :histories, :versionable_type, :string,  "versionable_type", :default => "Page", :null => false, :limit=>16
    add_index "histories", ["versionable_type", "versionable_id", "revision"], :name => "index_histories_on_versionables_and_rev", :unique => true
  end
end
