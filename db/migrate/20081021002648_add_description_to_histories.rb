class AddDescriptionToHistories < ActiveRecord::Migration
  def self.up
    add_column :histories, :description, :string, :null=>false, :default =>""
  end

  def self.down
    remove_column :histories, :description
  end
end
