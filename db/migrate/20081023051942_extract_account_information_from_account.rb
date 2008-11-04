class ExtractAccountInformationFromAccount < ActiveRecord::Migration
  def self.up
    #remove_index :users, :login
    data_migration = (User.count > 0)
    rename_table :users, :accounts
    add_index :accounts, :login, :unique => true

    add_column :accounts, :user_id, :integer, :null => false, :default => 0

    create_table:users do |t|
      t.string :name, :null => false, :limit=>40
      t.string :display_name, :null => false, :default=>""

      t.timestamps
    end

    if data_migration
      ActiveRecord::Base.transaction do
        Account.all.each do |a|
          u = User.new(:name=> a.name.blank? ? a.login : a.name) do |user|
                user.id = a.id
              end
          u.save_without_validation!
          a.user_id = u.id
          a.save_without_validation!
        end
      end
    end
  end

  def self.down
    drop_table :users
    remove_index :accounts, :login
    rename_table :accounts, :users
    add_index :users, :login, :unique => true
  end
end
