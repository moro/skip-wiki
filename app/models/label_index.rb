class LabelIndex < ActiveRecord::Base
  belongs_to :note
  has_many :label_indexings
  has_many :pages, :through => :label_indexings do
    def previous(order)
      load_target_with_label_indexings
      target.sort_by(&:order_in_label).reverse.detect{|page| page.order_in_label < order }
    end

    def next(order)
      load_target_with_label_indexings
      target.sort_by(&:order_in_label).detect{|page| page.order_in_label > order }
    end

    private
    def load_target_with_label_indexings
      with_scope(:find =>{:include => "label_indexings"}){ load_target }
    end
  end

  named_scope :has_pages, {:conditions => "EXISTS(SELECT lx.page_id FROM label_indexings AS lx WHERE #{quoted_table_name}.id = lx.label_index_id)"}

  validates_presence_of :display_name
  validates_uniqueness_of :display_name, :scope=>:note_id

  before_destroy :deletable?

  attr_accessible :display_name, :color, :note

  def self.no_label
    new(:display_name => _("No Labels"), :color => "#ffffff"){|l| l.default_label = true }
  end

  private
  def deletable?
    !default_label
  end
end

