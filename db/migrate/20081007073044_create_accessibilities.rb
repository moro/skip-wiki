class CreateAccessibilities < ActiveRecord::Migration
  def self.up
    create_table :accessibilities do |t|
      t.integer :note_id
      t.belongs_to :group, :polymorphic=>true

      t.timestamps
    end
  end

  def self.down
    drop_table :accessibilities
  end
end
