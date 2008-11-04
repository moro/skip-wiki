class CreateGroup < ActiveRecord::Migration
  def self.up
    # drop_table :groups
    create_table :groups do |t|
      t.belongs_to :backend, :polymorphic => true

      t.string :name, :null => false, :limit=>40
      t.string :display_name, :null => false, :limit=>256, :default=>""

      t.timestamps
    end

    SkipGroup.class_eval do
      has_many :memberships, :as => :group
      has_many :accessibilities, :as => :group
    end

    ActiveRecord::Base.transaction do
      BuiltinGroup.all.each do |bg|
        group = Group.create(:name => bg.note.name,
                             :display_name => "\"%s\"のグループ" % bg.note.display_name,
                             :backend => bg){|g| g.id = bg.id }

      end

      SkipGroup.all.each do |sg|
        group = Group.create(:name => sg.name + "_skip",
                             :display_name => "%s(SKIP)" % sg.display_name,
                             :backend => sg)
        sg.memberships.each{|m| m.update_attributes(:group_id, group.id) }
        sg.accessibilities.each{|a| a.update_attributes(:group_id, group.id) }
        Note.update_all("notes.owner_group_id = #{Integer(group.id)}", {:owner_group_id=>sg.id})
      end
    end

    remove_column :memberships, :group_type
    remove_column :accessibilities, :group_type
    remove_column :notes, :owner_group_type
  end

  def self.down
    remove_column :memberships, :group_type, :string
    remove_column :accessibilities, :group_type, :string
    remove_column :notes, :owner_group_type, :string

    drop_table :groups
  end
end
