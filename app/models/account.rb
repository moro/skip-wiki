class Account < ActiveRecord::Base
  include Authentication
  include Authentication::ByCookieToken

  belongs_to :user
  validates_associated :user

  named_scope :fulltext, proc{|word|
    return {} if word.blank?
    w = "%#{word}%"
    {:conditions => ["login LIKE ? OR name LIKE ? OR email LIKE ?", w, w, w]}
  }
end

