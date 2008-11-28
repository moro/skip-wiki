class AttachmentsController < ApplicationController
  layout "notes"
  helper_method :current_target, :target_attachments_url, :target_attachment_url

  def index
    @attachments = current_target.attachments.find(:all)
    @attachment = current_target.attachments.build

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
  end

  def create
    @attachment = current_target.attachments.build(params[:attachment])
    if @attachment.save
      redirect_to target_attachments_url
    else
      render :action => "new"
    end
  end

  def destroy
  end

  private
  def current_target
    @_current_target ||= \
      params[:page_id] ? current_note.pages.find(params[:page_id]) : current_note
  end

  def target_attachments_url
    params[:page_id] ? note_page_attachments_url(current_note, current_target) \
                     : note_attachments_url(current_target)
  end

  def target_attachment_url(at)
    at.attachable_type == "Page" ? note_page_attachment_url(current_note, current_target, at) \
                                 : note_attachment_url(current_target, at)
  end
end
