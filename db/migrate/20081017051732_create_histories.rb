class CreateHistories < ActiveRecord::Migration
  def self.up
    create_table :histories do |table|
      table.with_options(:null=>false) do |t|
        t.belongs_to :versionable, :polymorphic=>true
        t.integer :user_id
        t.integer :revision
        t.integer :content_id
      end

      table.timestamps
    end
    add_index :histories, [:versionable_type, :versionable_id, :revision]
  end

  def self.down
    drop_table :histories
  end
end
