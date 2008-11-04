class BuiltinGroup < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"
  has_one  :group, :as => "backend"
end
