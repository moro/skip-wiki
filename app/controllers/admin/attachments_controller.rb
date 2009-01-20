class Admin::AttachmentsController < Admin::ApplicationController
  helper_method :target_attachment_url

  def index
    @attachments = requested_note.attachments
  end

end
