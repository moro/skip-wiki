class SchemaV010 < ActiveRecord::Migration
  def self.up
    fk_options = {:null => false, :default => 0}

    create_table "accessibilities" do |t|
      t.integer  "note_id", fk_options
      t.integer  "group_id", fk_options
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "accessibilities", %w(note_id group_id), :unique => true

    create_table "accounts" do |t|
      t.string   "login",                     :limit => 40
      t.string   "name",                      :limit => 100, :default => ""
      t.string   "email",                     :limit => 100, :default => ""
      t.string   "identity_url",              :limit => 40,  :default => ""
      t.string   "crypted_password",          :limit => 40,  :default => "", :null => false
      t.string   "salt",                      :limit => 40,  :default => "", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "remember_token",            :limit => 40
      t.datetime "remember_token_expires_at"
      t.integer  "user_id", fk_options
    end

    add_index "accounts", ["login"], :name => "index_accounts_on_login", :unique => true

    create_table "builtin_groups" do |t|
      t.integer  "owner_id", fk_options
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "builtin_groups", ["owner_id"]

    create_table "categories" do |t|
      t.string   "name"
      t.string   "display_name"
      t.string   "description"
      t.string   "lang",         :limit => 2
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "contents" do |t|
      t.binary   "data",       :limit => 20.megabytes
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "groups" do |t|
      t.integer  "backend_id", fk_options
      t.string   "backend_type"
      t.string   "name",         :limit => 40,                  :null => false
      t.string   "display_name", :limit => 256, :default => "", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index :groups, %w(backend_id backend_type)

    create_table "histories" do |t|
      t.integer  "versionable_id",  fk_options
      t.string   "versionable_type", :default => "", :null => false
      t.integer  "user_id", fk_options
      t.integer  "revision",   :default =>0,:null => false
      t.integer  "content_id", fk_options
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "description",      :default => "", :null => false
    end

    add_index "histories", ["versionable_type", "versionable_id", "revision"], :name => "index_histories_on_versionables_and_rev", :unique=>true

    create_table "label_indexings" do |t|
      t.integer  "label_index_id", fk_options
      t.integer  "page_id",        fk_options
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "label_indexings", ["label_index_id", "page_id"], :name => "index_label_indexings_on_label_index_and_page", :unique=>true

    create_table "label_indices" do |t|
      t.string  "name",                      :default => "",        :null => false
      t.string  "display_name",              :default => "",        :null => false
      t.string  "color",        :limit => 7, :default => "#FFFFFF", :null => false
      t.integer "note_id",      fk_options
    end

    create_table "memberships" do |t|
      t.integer  "user_id", fk_options
      t.integer  "group_id", fk_options
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "memberships", ["user_id", "group_id"], :name => "index_memberships_on_user_and_group"

    create_table "notes" do |t|
      t.string   "name",           :default => "", :null => false
      t.string   "display_name",   :default => "", :null => false
      t.integer  "publicity",      :default => 2,  :null => false
      t.datetime "deleted_on"
      t.integer  "category_id", fk_options
      t.integer  "owner_group_id", fk_options
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "description",    :default => "", :null => false
    end

    create_table "open_id_authentication_associations" do |t|
      t.integer "issued"
      t.integer "lifetime"
      t.string  "handle"
      t.string  "assoc_type"
      t.binary  "server_url"
      t.binary  "secret"
    end

    create_table "open_id_authentication_nonces" do |t|
      t.integer "timestamp",  :null => false
      t.string  "server_url"
      t.string  "salt",       :null => false
    end

    create_table "pages" do |t|
      t.integer  "note_id", fk_options
      t.integer  "last_modied_user_id", fk_options
      t.string   "name",                                                  :null => false
      t.string   "display_name",                                          :null => false
      t.string   "format_type",         :limit => 16, :default => "html", :null => false
      t.datetime "published_at",                                          :null => false
      t.datetime "deleted_at"
      t.integer  "lock_version",                      :default => 0,      :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "skip_accounts" do |t|
      t.string   "skip_uid",   :limit => 16,                :null => false
      t.integer  "user_id",    fk_options
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "skip_groups" do |t|
      t.string   "name",         :limit => 40,                  :null => false
      t.string   "display_name", :limit => 256, :default => "", :null => false
      t.string   "gid",          :limit => 16,                  :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "users" do |t|
      t.string   "name",         :limit => 40,                 :null => false
      t.string   "display_name",               :default => "", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
#     [
#       ["accessibilities", %w(note_id group_id)],
#       ["accounts", "index_accounts_on_login"],
#       ["accounts", ["identity_url"]],
#       ["accounts", ["user_id"]],
#       ["builtin_groups", ["owner_id"]],
#       [:groups, %w(backend_id backend_type)],
#       ["histories", "index_histories_on_versionables_and_rev"],
#       ["label_indexings",  "index_label_indexings_on_label_index_and_page"],
#       ["memberships", "index_memberships_on_user_and_group"]
#     ].each {|t,n| remove_index(t, :name => n) }

    %w[ accessibilities
        accounts
        builtin_groups
        categories
        contents
        groups
        histories
        label_indexings
        label_indices
        memberships
        notes
        open_id_authentication_associations
        open_id_authentication_nonces
        pages
        skip_accounts
        skip_groups
        users
     ].each{|t| drop_table t }
  end
end
