class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |table|
      table.with_options(:null=>false) do |t|
        t.integer :note_id, :default=>0
        t.integer :last_modied_user_id, :default=>0
        #t.integer :current_content_id, :default=>0
        t.string :name
        t.string :display_name
        t.string :format_type, :limit=>"16"
        t.timestamp :published_at
        t.timestamp :deleted_at, :null=>true
        t.integer :lock_version
      end

      table.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end
