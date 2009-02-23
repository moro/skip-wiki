class User < ActiveRecord::Base
  has_friendly_id :name

  validates_presence_of     :name
  validates_length_of       :name, :within => 3..40
  validates_uniqueness_of   :name
  validates_format_of       :name, :with => Authentication.login_regex, :message => Authentication.bad_login_message
  validates_presence_of     :display_name
  validates_length_of       :display_name, :within => 3..256

  has_many :memberships, :dependent => :destroy do
    def replace_by_type(klass, *groups)
      remains = find(:all, :include=>:group).select{|m| m.group.backend_type != klass.name }
      news = groups.map{|g| proxy_reflection.klass.new(:group=>g,:user=>proxy_owner) }
      replace(remains + news)
    end
  end
  has_many :groups, :through => :memberships
  has_many :builtin_groups, :foreign_key => "owner_id"

  has_one :account
  has_one :skip_account

  scope_do :named_acl
  named_acl :notes

  named_scope :fulltext, proc{|word|
    return {} if word.blank?
    # TODO
    # quoted_table_nameの概要を諸橋さんに聞く
    # [ActiveRecord]
    # def self.quoted_table_name
    #   self.connection.quote_table_name(self.table_name)
    # end
    w = "%#{word}%"
    {:conditions => ["name LIKE ? OR display_name LIKE ?", w, w]}
  }

  def name=(value)
    write_attribute :name, (value ? value.downcase : nil)
  end

  def skip_uid
    skip_account ? skip_account.skip_uid : SkipAccount.skip_uid(account.identity_url)
  end

  def skip_uid=(uid)
    build_skip_account(:skip_uid=>uid) unless uid.blank?
  end

  def build_skip_membership
    groups = SkipGroup.fetch_and_store(skip_uid).map do |sg|
      sg.group ||= sg.build_group(:name=>sg.name, :display_name=>sg.display_name + "(SKIP)")
    end
    memberships.replace_by_type(SkipGroup, *groups)
  end

  def build_note(note_params)
    NoteBuilder.new(self, note_params).note
  end
end

