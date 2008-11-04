class Membership < ActiveRecord::Base
  belongs_to :user, :dependent => :destroy
  belongs_to :group, :dependent => :destroy

  validates_presence_of :user
  validates_presence_of :group
end
