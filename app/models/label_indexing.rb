class LabelIndexing < ActiveRecord::Base
  belongs_to :label_index
  belongs_to :page

  validates_presence_of :label_index, :page
  validates_uniqueness_of :label_index_id, :scope => "page_id"

  before_validation_on_create :increment_page_order
  private
  def increment_page_order
    max = self.class.maximum(:page_order, :conditions => {:label_index_id => label_index_id })
    self.page_order = (max || 0).succ
  end
end
