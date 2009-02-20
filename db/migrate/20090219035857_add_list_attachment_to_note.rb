class AddListAttachmentToNote < ActiveRecord::Migration
  def self.up
    add_column :notes, :list_attachments, :bool, :default => false
  end

  def self.down
    remove_column :notes, :list_attachments
  end
end
