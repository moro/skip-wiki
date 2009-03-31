class LabelIndex < ActiveRecord::Base
  NAVIGATION_STYLE_NONE = 0
  NAVIGATION_STYLE_TOGGLE = 1
  NAVIGATION_STYLE_ALWAYS = 2

  def self.navigation_styles
    [NAVIGATION_STYLE_NONE, NAVIGATION_STYLE_TOGGLE, NAVIGATION_STYLE_ALWAYS]
  end

  belongs_to :note
  has_many :label_indexings
  has_many :pages, :through => :label_indexings

  scope_do :has_children
  has_children :pages

  validates_presence_of :display_name
  validates_uniqueness_of :display_name, :scope=>:note_id

  before_destroy :deletable?

  attr_accessible :display_name, :color, :note

  def self.no_label
    new(:display_name => _("No Labels"), :color => "#ffffff"){|l| l.default_label = true }
  end

  private
  # TODO deleteのエラーメッセージの伝達にerrorsを使う是非を検討する
  def deletable?
    errors.clear
    errors.add :base, _("Can not delete default label") if default_label
    errors.add :base, _("Move or delete related pages before delete the label") unless pages.empty?
    errors.empty?
  end
end

