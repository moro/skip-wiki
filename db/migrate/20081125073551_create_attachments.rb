class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.integer :attachable_id, :null => false
      t.string :attachable_type, :null => false, :limit => 16
      t.string :content_type, :null => false
      t.string :filename, :null => false
      t.string :display_name, :null => false
      t.integer :size, :null => false, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :attachments
  end
end
