class AddLabelNavigationStyleToNote < ActiveRecord::Migration
  def self.up
    default = (defined? LabelIndex::NAVIGATION_STYLE_NONE) ? LabelIndex::NAVIGATION_STYLE_NONE : 0
    add_column :notes, :label_navigation_style, :integer, :default => default
  end

  def self.down
    remove_column :notes, :label_navigation_style
  end
end
