class Account < ActiveRecord::Base
  belongs_to :user
  validates_associated :user
  validates_presence_of :identity_url
  validates_uniqueness_of :identity_url
end

