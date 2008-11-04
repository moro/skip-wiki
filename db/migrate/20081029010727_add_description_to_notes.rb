class AddDescriptionToNotes < ActiveRecord::Migration
  def self.up
    add_column :notes, :description, :text, :null=>false, :default=>""
  end

  def self.down
    remove_column :notes, :description
  end
end
