class AttachmentsController < ApplicationController
  include IframeUploader
  include ActionView::Helpers::NumberHelper # to format file size on JSON

  before_filter :writable_user_required, :only => %w[new create destroy]
  before_filter :only_if_list_attachments_or_group_member, :only => %w[index]

  def index
    @attachments = current_note.attachments.
      find(:all, :order =>"#{Attachment.quoted_table_name}.updated_at DESC")

    respond_to do |format|
      format.html do
        ajax_upload? ? render(:text => "") : render
      end
      format.js do
        render :json => @attachments.map{|a| {:attachment=>attachment_to_json(a)} }
      end
    end
  end

  def show
    @attachment = current_note.attachments.find(params[:id])
    opts = {:filename => @attachment.filename, :type => @attachment.content_type }
    opts[:disposition] = "inline" if params[:position] == "inline"

    send_file(@attachment.full_filename, opts)
  end

  def new
    @attachment = current_note.attachments.build
  end

  def create
    @attachment = current_note.attachments.build(params[:attachment])
    if @attachment.save
      opt = ajax_upload? ? IframeUploader.index_opt : {}
      redirect_to note_attachments_url(current_note, opt)
    else
      render :action => "new"
    end
  end

  def destroy
    @attachment = current_note.attachments.find(params[:id])
    @attachment.destroy

    flash[:notice]= _("Deleted %{name}") %
          {:name => "#{_("Attachment")} #{@attachment.display_name}"}

    redirect_to(note_attachments_path(current_note))
  end

  private
  def attachment_to_json(atmt)
    returning(atmt.attributes.slice("content_type", "filename", "display_name")) do |json|
      json[:path] = note_attachment_path(current_note, atmt)
      json[:inline] = note_attachment_path(current_note, atmt, :position=>"inline") if atmt.image?
      json[:size] = number_to_human_size(atmt.size)

      json[:updated_at] = atmt.updated_at.strftime("%Y/%m/%d %H:%M")
      json[:created_at] = atmt.created_at.strftime("%Y/%m/%d %H:%M")
    end
  end

  def select_layout
    ajax_upload? ? nil : "notes"
  end

  def only_if_list_attachments_or_group_member
    unless (current_note.accessible?(current_user) || current_note.list_attachments)
      head(:forbidden)
    end
  end

  def writable_user_required
    unless current_note.accessible?(current_user)
      head(:forbidden)
    end
  end
end
