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

  def accessible(klass)
    pub_cond, pub_param = klass.const_get("PUBLIC_CONDITION")

    klass.scoped(:conditions=>[<<-COND, pub_param.merge(:accessable_id => self.id)])
    #{pub_cond}
 OR #{klass.table_name}.id IN (
    SELECT a.note_id FROM accessibilities AS a
    JOIN   memberships AS m ON m.group_id = a.group_id
    WHERE  m.user_id = :accessable_id
 )
COND
  end

end

