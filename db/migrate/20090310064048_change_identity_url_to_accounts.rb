class ChangeIdentityUrlToAccounts < ActiveRecord::Migration
  def self.up
    change_column :accounts, :identity_url, :string, :limit=>80, :default => ""
  end

  def self.down
  end
end
