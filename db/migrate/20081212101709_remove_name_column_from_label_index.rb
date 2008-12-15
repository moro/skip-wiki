class RemoveNameColumnFromLabelIndex < ActiveRecord::Migration
  def self.up
    remove_column :label_indices, :name
    add_column :label_indices, :default_label, :boolean, :default => false

    ActiveRecord::Base.transaction do
      Note.find(:all).each do |note|
        note.default_label || note.label_indices << LabelIndex.no_label
        note.pages.each do |page|
          page.label_index = note.default_label unless page.label_index_id
        end
      end
    end
  end

  def self.down
    add_column :label_indices, :name, :string, :null => false, :limit=>16
    remove_column :label_indices, :default_label
  end
end
