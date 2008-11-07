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

  validates_presence_of :name
  validates_uniqueness_of :name, :scope=>:note_id
end
