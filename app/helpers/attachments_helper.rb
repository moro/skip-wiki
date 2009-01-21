module AttachmentsHelper
  def uploader_js_option
    with_options(IframeUploader.index_opt) do |opt|
      {:target => IframeUploader::UPLOAD_KEY,
       :src => {:form =>   opt.new_note_attachment_path(current_note),
                :target => opt.note_attachments_path },
       :callback => "refreshAttachments" }
    end
  end
end
