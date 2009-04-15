class AddListAttachmentToNote < ActiveRecord::Migration
  def self.up
    add_column :notes, :list_attachments, :boolean, :default => false
  end

  def self.down
    remove_column :notes, :list_attachments
  end
end
