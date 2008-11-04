class CreateSkipGroups < ActiveRecord::Migration
  def self.up
    create_table :skip_groups do |t|
      t.string :name, :null => false, :limit=>40
      t.string :display_name, :null => false, :limit=>256, :default=>""
      t.string :gid, :null => false, :limit=>16 # FIXME

      t.timestamps
    end
  end

  def self.down
    drop_table :skip_groups
  end
end
