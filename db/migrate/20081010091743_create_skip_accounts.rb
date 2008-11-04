class CreateSkipAccounts < ActiveRecord::Migration
  def self.up
    create_table :skip_accounts do |t|
      t.string :skip_uid, :null=>false, :limit=>16 # TODO
      t.integer :user_id, :null=>false, :default=>0

      t.timestamps
    end
  end

  def self.down
    drop_table :skip_accounts
  end
end
