class AddDefaultsToPage < ActiveRecord::Migration
  def self.up
    change_column :pages, :format_type, :string, :null => false, :default => "html"
    change_column :pages, :lock_version, :integer, :null => false, :default => 0
  end

  def self.down
    # no-op
  end
end
