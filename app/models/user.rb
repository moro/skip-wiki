class User < ActiveRecord::Base
  has_friendly_id :name

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

  def accessible_or_public_notes(parent = Note)
    pub_cond, pub_param = Note.const_get("PUBLIC_CONDITION")
    parent.scoped(:conditions=>["#{pub_cond} OR #{parent.table_name}.id IN (#{accessible_query})",
                                pub_param.merge(:accessable_id => self.id)])
  end

  def accessible_notes(parent = Note)
    parent.scoped(:conditions=>["#{parent.table_name}.id IN (#{accessible_query})",{:accessable_id => id}])
  end

  private
  def accessible_query
    <<EOS
    SELECT a.note_id FROM accessibilities AS a
    JOIN   memberships AS m ON m.group_id = a.group_id
    WHERE  m.user_id = :accessable_id
EOS
  end
end

