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

  has_many :accessibilities
  has_many :label_indices
  has_many :pages do
    def add(attrs, user)
      edit_page_content(build, attrs, user)
    end

    def update(query_name, attrs, user)
      edit_page_content(find(query_name), attrs, user)
    end

    private
    def edit_page_content(page, attrs, user)
      returning(page) do
        page.edit(attrs[:content], user)
        page.attributes = attrs.except(:content)
      end
    end
  end

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

  private
  def add_accessibility_to_owner_group
    accessibilities << Accessibility.new(:group=>owner_group)
  end
end
