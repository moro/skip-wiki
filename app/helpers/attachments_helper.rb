module AttachmentsHelper
  def iframe_uploader_opt(callback_name)
    {:target => AttachmentsController::AJAX_UPLOAD_KEY,
     :src => {:form =>   new_note_attachment_path(current_note, ajax_upload_option),
              :target => note_attachments_path(ajax_upload_option) },
     :callback => callback_name}
  end
end
