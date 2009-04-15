class ChangeNoteDefaultProperty < ActiveRecord::Migration
  def self.up
    change_column :notes, :list_attachments, :boolean, :default => true, :null => false
    change_column :notes, :label_navigation_style, :integer, :default => LabelIndex::NAVIGATION_STYLE_ALWAYS
  end

  def self.down
    change_column :notes, :list_attachments, :boolean, :default => false
    change_column :notes, :label_navigation_style, :integer, :default => LabelIndex::NAVIGATION_STYLE_NONE
  end
end
