class Attachment < ActiveRecord::Base
  has_attachment :storage => :file_system,
                 :size => 1..100.megabytes, # FIXME
                 :path_prefix => "assets/uploaded_data/#{::Rails.env}",
                 :processor => :none
  belongs_to :attachable, :polymorphic => true

  attr_accessible :display_name, :uploaded_data

  validates_presence_of :display_name
  validates_as_attachment

  def uploaded_data=(data)
    super
    self.display_name ||= data.original_filename
  end
end
