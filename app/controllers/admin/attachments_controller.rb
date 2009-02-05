class Admin::AttachmentsController < Admin::ApplicationController
  layout "admin_notes"
  def index
    @attachments = requested_note.attachments
  end

  def create
    @attachment = requested_note.attachments.build(params[:attachment])
    if @attachment.save
      flash[:notice] = _("Attachment was created successfully.")
    else
      flash[:error] = _("Attachment can't created.")
    end 
    redirect_to admin_note_attachments_url(requested_note)
  end

  def destroy
    begin
      @attachment = Attachment.find(params[:id])
      @attachment.destroy
      flash[:notice] = _("Attachment was deleted successfully")
      redirect_to admin_note_attachments_url
    rescue => ex
      flash[:error] = "Failed to delete attachment"
    end
  end
end
