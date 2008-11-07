class AddPageOrderToLabelIndexings < ActiveRecord::Migration
  def self.up
    add_column :label_indexings, :page_order, :integer, :null=>false,:default=>0
  end

  def self.down
    remove_column :label_indexings, :page_order
  end
end
