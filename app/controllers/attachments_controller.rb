class AttachmentsController < ApplicationController
  layout "notes"
  def index
    @attachments = current_note.attachments.find(:all)
    @attachment = current_note.attachments.build

    respond_to do |format|
      format.html
      format.js do
        render :json => @attachments.map{|a| {:attachment=>attachment_to_json(a)} }
      end
    end
  end

  def show
    @attachment = current_note.attachments.find(params[:id])
    opts = {:filename => @attachment.filename,
            :type => @attachment.content_type }
    opts[:disposition] = "inline" if params[:position] == "inline"

    send_file(@attachment.full_filename, opts)
  end

  def create
    @attachment = current_note.attachments.build(params[:attachment])
    if @attachment.save
      redirect_to note_attachments_url(current_note)
    else
      render :action => "new"
    end
  end

  def destroy
  end

  private
  def attachment_to_json(atmt)
    returning(atmt.attributes.slice("filename", "display_name", "created_at", "updated_at")) do |json|
      json[:path] = note_attachment_path(current_note, atmt)
      json[:inline] = note_attachment_path(current_note, atmt, :position=>"inline") if atmt.image?
    end
  end
end
