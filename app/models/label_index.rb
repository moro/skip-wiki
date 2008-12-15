class LabelIndex < ActiveRecord::Base
  belongs_to :note
  has_many :label_indexings
  has_many :pages, :through => :label_indexings do
    def previous(order)
      col = LabelIndexing.quoted_table_name + ".page_order"
      find(:first, :conditions => ["#{col} < ?", order], :order => "#{col} DESC")
    end

    def next(order)
      col = LabelIndexing.quoted_table_name + ".page_order"
      find(:first, :conditions => ["#{col} > ?", order], :order => "#{col} ASC")
    end
  end

  validates_presence_of :display_name
  validates_uniqueness_of :display_name, :scope=>:note_id

  attr_accessible :display_name, :color, :note

  def self.no_label
    new(:display_name => _("No Labels"), :color => "#ffffff"){|l| l.default_label = true }
  end
end

