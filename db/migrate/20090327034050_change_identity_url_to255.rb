class ChangeIdentityUrlTo255 < ActiveRecord::Migration
  def self.up
    change_column :accounts, :identity_url, :string, :limit=>255, :null => false
  end

  def self.down
    change_column :accounts, :identity_url, :string, :limit=>80, :default => ""
  end
end
