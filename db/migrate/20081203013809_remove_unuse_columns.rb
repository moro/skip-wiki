class RemoveUnuseColumns < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :crypted_password
    remove_column :accounts, :salt
  end

  def self.down
    add_column :accounts, "crypted_password", :limit => 40,  :default => "", :null => false
    add_column :accounts, "salt", :limit => 40,  :default => "", :null => false
  end
end
