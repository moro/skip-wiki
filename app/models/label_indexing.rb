class LabelIndexing < ActiveRecord::Base
  belongs_to :label_index
  belongs_to :page

  validates_presence_of :label_index, :page
  validates_uniqueness_of :label_index_id, :scope => "page_id"
end
