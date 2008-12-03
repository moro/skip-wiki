class Page < ActiveRecord::Base
  CRLF = /\r?\n/

  has_friendly_id :name
  attr_reader :new_history
  attr_writer :label_index_id
  attr_writer :order_in_label

  belongs_to :note
  has_many :histories, :order => "histories.revision DESC"
  has_many :label_indexings
  has_one  :label_index, :through => :label_indexings

  has_many :attachments, :as => :attachable

  validates_associated :new_history, :if => :new_history
  validates_presence_of  :name, :published_at
  validates_inclusion_of :format_type, :in => %w[hiki html]

  named_scope :recent, proc{|*args|
    {
     :order => "#{table_name}.updated_at DESC",
     :limit => args.shift || 10 # default
    }
  }

  # TODO 採用が決まったら回帰テスト書く
  named_scope :last_modified_per_notes, proc{|note_ids|

    {:conditions => [<<-SQL, note_ids] }
    #{quoted_table_name}.id IN (
      SELECT p0.id
      FROM   #{quoted_table_name} AS p0
      INNER JOIN (
        SELECT p2.note_id AS note_id, MAX(p2.updated_at) AS updated_at
        FROM #{quoted_table_name} AS p2
        WHERE p2.note_id IN (?)
        GROUP BY p2.note_id
      ) AS p1 USING (note_id, updated_at)
    )
SQL
  }

  named_scope :fulltext, proc{|keyword|
    hids = History.find_all_by_head_content(keyword).map(&:id)
    if hids.empty?
      { :conditions => "1 = 2" } # force false
    else
      { :conditions => ["#{History.quoted_table_name}.id IN (?)", hids],
        :include => :histories }
    end
  }

  named_scope :no_labels, proc{
    { :conditions => <<SQL }
#{quoted_table_name}.id IN (
  SELECT p.id
  FROM pages AS p
  LEFT JOIN label_indexings AS l ON l.page_id = p.id
  WHERE l.id IS NULL
)
SQL
  }

  named_scope :nth, proc{|*args|
    nth, order, = args
    order ||= quoted_table_name + ".updated_at DESC"
    { :limit => 1,
      :offset => Integer(nth) - 1,
      :order => order }
  }

  before_validation :assign_default_pubulification
  after_save :reset_history_caches, :update_label_index

  def self.front_page(attrs = {})
    attrs = {
      :name => "FrontPage",
      :display_name => _("FrontPage"),
      :format_type => "html",
      :published_at => Time.now,
    }.merge(attrs)
    new(attrs)
  end

  def self.front_page_content
    File.read(File.expand_path("assets/front_page.html.erb", ::Rails.root))
  end

  def order_in_label
    if idx = self.label_indexings.first
      idx.page_order
    else
      cond = ["#{self.class.quoted_table_name}.updated_at > ?", updated_at]
      @order_in_label ||= note.pages.no_labels.count(:conditions=>cond).succ
    end
  end

  def head
    histories.first
  end

  def diff(from, to)
    revs = [from, to].map(&:to_i)
    hs = histories.find(:all, :conditions => ["histories.revision IN (?)", revs],
                              :include => :content)
    from_content, to_content = revs.map{|r| hs.detect{|h| h.revision == r }.content }

    Diff::LCS.sdiff(from_content.data.split(CRLF),
                    to_content.data.split(CRLF)).map(&:to_a)
  end

  def label_index_id
    @label_index_id || (label_index ? label_index.id : nil)
  end

  def content(revision=nil)
    if revision.nil? # HEAD
      (history =  @new_history || head) ? history.content.data : ""
    else
      histories.detect{|h| h.revision == revision.to_i }.content.data
    end
  end

  def revision
    new_record? ? 0 : (@revision ||= load_revision)
  end

  def edit(content, user)
    return if content == self.content
    self.updated_at = Time.now.utc
    @new_history = histories.build(:content => Content.new(:data => content),
                                   :user => user,
                                   :revision => revision.succ)
  end

  private
  def assign_default_pubulification
    self.published_at ||= Time.now
  end

  def reset_history_caches
    @revision = @new_history = nil
  end

  def load_revision
    histories.maximum(:revision) || 0
  end

  def update_label_index
    if label_index_id
      self.label_index = note.label_indices.find(label_index_id)
    end
  end
end
