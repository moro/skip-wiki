class MergeAccountTable < ActiveRecord::Migration
  def self.up
    options = {:null => false, :limit => 255}

    if ActiveRecord::Base.connection.adapter_name == "SQLite"
      options[:default] = ""
    end

    add_column :users, :identity_url, :string, options

    begin
      Account
    rescue NameError, LoadError => why
      Object.const_set("Account", Class.new(ActiveRecord::Base))
    end

    ActiveRecord::Base.transaction do
      User.find(:all).each do |u|
        unless acc = Account.find_by_user_id(u.id)
          puts "#{u} has no account!"
          next
        end
        u.update_attribute(:identity_url, acc.identity_url)
      end
    end
    
    drop_table :accounts
  end

  def self.down
    create_table :accounts do |t|
      t.string :identity_url, :limit => 255, :null => false
      t.integer :user_id, :null => false
    end
    Object.const_set("Account", Class.new(ActiveRecord::Base)) unless defined?(Account)
    ActiveRecord::Base.transaction do
      User.find(:all).each do |u|
        Account.create!(:identity_url => u.identity_url, :user_id => u.id)
      end
    end

    remove_column :users, :identity_url
  end
end
