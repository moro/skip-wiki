class AddFamilyFlagToClientApp < ActiveRecord::Migration
  def self.up
    add_column :client_applications, :family, :boolean, :default => false
  end

  def self.down
    remove_column :client_applications, :family
  end
end
