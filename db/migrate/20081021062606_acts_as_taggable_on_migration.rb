class ActsAsTaggableOnMigration < ActiveRecord::Migration
  def self.up
    create_table :label_indices do |t|
      t.string :name, :null=>false, :default=>""
      t.string :display_name, :null=>false, :default=>""
      t.string :color, :null=>false, :default=>"#FFFFFF", :limit=>7
      t.belongs_to :note, :null=>false, :default=>0
    end

    create_table :label_indexings do |t|
      t.belongs_to :label_index, :null => false, :default=>0
      t.belongs_to :page, :null => false, :default=>0

      t.timestamps
    end

    add_index :label_indexings, [:label_index_id, :page_id]
  end

  def self.down
    drop_table :label_indexings
    drop_table :label_indices
  end
end
