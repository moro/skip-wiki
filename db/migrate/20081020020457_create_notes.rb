class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|

      t.string   :name, :default=>"", :null=>false
      t.string   :display_name, :default=>"", :null=>false
      t.integer  :publicity, :null=>false, :default=>Note::PUBLICITY_MEMBER_ONLY
      t.datetime :deleted_on
      t.belongs_to :category, :default=>0, :null=>false
      t.belongs_to :owner_group, :polymorphic=>true

      t.timestamps
    end
  end

  def self.down
    drop_table :notes
  end
end
