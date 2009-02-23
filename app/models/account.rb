class Account < ActiveRecord::Base
  include Authentication
  include Authentication::ByCookieToken

  belongs_to :user
  validates_associated :user
end

