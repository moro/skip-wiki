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
    returning Note.new(note_params.dup) do |note|
      note.owner_group = find_or_initialize_group(note)
      note.build_front_page(self)
    end
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

  private
  def find_or_initialize_group(note)
    case note.group_backend_type
    when "BuiltinGroup"
      attrs = {:name => note.name,
               :display_name => _("%{name} group") % {:name=>note.display_name},
               :backend=>builtin_groups.build }
      Group.new(attrs){|g| g.memberships = [Membership.new(:group => g, :user=>self)] }
    when "SkipGroup"
      groups.find(:first, :conditions=>{:backend_type => note.group_backend_type,
                                        :backend_id => note.group_backend_id})
    end
  end
end

