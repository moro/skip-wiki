class Attachment < ActiveRecord::Base
  has_attachment :storage => :file_system,
                 :path_prefix => "assets/uploaded_data",
                 :processor => :none
  belongs_to :attachable, :polymorphic => true

  attr_accessible :display_name, :uploaded_data

  validates_presence_of :display_name
  validates_as_attachment
end
