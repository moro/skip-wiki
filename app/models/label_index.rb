class LabelIndex < ActiveRecord::Base
  belongs_to :note
  has_many :label_indexings
  has_many :pages, :through => :label_indexings

  validates_presence_of :name
  validates_uniqueness_of :name, :scope=>:note_id
end
