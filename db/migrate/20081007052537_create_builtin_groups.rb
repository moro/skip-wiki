class CreateBuiltinGroups < ActiveRecord::Migration
  def self.up
    create_table :builtin_groups do |t|
      t.integer :owner_id

      t.timestamps
    end
  end

  def self.down
    drop_table :builtin_groups
  end
end
