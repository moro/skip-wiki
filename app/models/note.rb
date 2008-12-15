class Note < ActiveRecord::Base
  PUBLICITY_READABLE = 0
  PUBLICITY_WRITABLE = 1
  PUBLICITY_MEMBER_ONLY = 2

  PUBLIC_CONDITION = ["#{table_name}.publicity IN (:publicity)",
                      {:publicity => [PUBLICITY_READABLE, PUBLICITY_WRITABLE]} ].freeze

  WIZARD_STEPS = [ N_("管理対象の選択"), N_("カテゴリの選択"), N_("公開範囲の選択"),
                   N_("名前の入力"), N_("説明の入力"), N_("デザインの選択"), N_("確認") ].freeze

  has_friendly_id :name

  validates_presence_of :owner_group, :name, :display_name, :description
  validates_uniqueness_of :name
  validates_inclusion_of :publicity, :in => (PUBLICITY_READABLE..PUBLICITY_MEMBER_ONLY)

  belongs_to :owner_group, :class_name => "Group"
  belongs_to :category

  has_many :accessibilities
  has_many :label_indices do
    def find_or_empty_label(id)
      id == "none" ? EmptyLabel.new(proxy_owner) : find(id)
    end
  end
  has_many :pages do
    def add(attrs, user)
      returning(build) do |page|
        page.edit(attrs[:content], user)
        page.attributes = attrs.except(:content)
        page.label_index_id ||= proxy_owner.default_label.id
      end
    end
  end

  has_many :attachments, :as => :attachable

  named_scope :public, {:conditions=>PUBLIC_CONDITION}

  named_scope :recent, proc{|*args|
    {
     :order => "#{table_name}.updated_at DESC",
     :limit => args.shift || 10 # default
    }
  }

  named_scope :fulltext, proc{|word|
    return {} if word.blank?
    t = quoted_table_name
    w = "%#{word}%"
    {:conditions => ["#{t}.display_name LIKE ? OR #{t}.description LIKE ?", w, w]}
  }
  before_create :add_accessibility_to_owner_group
  before_create :add_default_label

  attr_writer :group_backend_type
  attr_accessor :group_backend_id

  def group_backend_type
    @group_backend_type || owner_group.backend_type
  end

  def groups=(groups)
    accessibilities.replace groups.map{|g| accessibilities.build(:group=>g) }
  end

  def groups
    accessibilities.map(&:group)
  end

  def build_front_page(user)
    returning Page.front_page do |page|
      page.edit(Page.front_page_content, user)
      self.pages << page
    end
  end

  def accessible?(user)
    accessibilities.find(:first,
      :joins => "JOIN memberships AS m ON m.group_id = accessibilities.group_id",
      :conditions => ["m.user_id = ?", user.id]
    )
  end

  def to_param
    name_changed? ? name_was : name
  end

  def default_label
    label_indices.detect(&:default_label)
  end

  private
  def add_accessibility_to_owner_group
    accessibilities << Accessibility.new(:group=>owner_group)
  end

  def add_default_label
    label_indices << LabelIndex.no_label
  end
end
