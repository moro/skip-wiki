class RemoveUnunseColumns < ActiveRecord::Migration
  def self.up

    remove_index "accounts", :name => "index_accounts_on_login"
    remove_column "accounts", "login"
    remove_column "accounts", "name"
    remove_column "accounts", "email"
  end

  def self.down
    add_column "accounts", "login", :string, :limit => 40
    add_column "accounts", "name",  :string, :limit => 100
    add_column "accounts", "email", :string, :limit => 100
    add_index "accounts", ["login"], :name => "index_accounts_on_login", :unique => true
  end
end
