class Admin::NotesController < Admin::ApplicationController
  layout "admin_notes"

  # GET 
  def index
    @notes = Note.fulltext(params[:keyword])
  end

  def show
    @note = Note.find(params[:id])
  end

  def edit
    @note = Note.find(params[:id])    
  end

  # PUT /admin/notes/1
  def update
    @note = Note.find(params[:id])
    if @note.update_attributes(params[:note])
      flash[:notice] = _('Note was successfully updated.')
      redirect_to admin_note_path(params[:id])
    else
      flash[:error] = _('validation error')
      redirect_to :action => 'edit'
    end
  end

  def destroy
    # TODO 現在ノートのみ物理削除
    begin
      @note = Note.find(params[:id])
      @note.destroy
      flash[:notice] = _("Note was deleted successfully")
      redirect_to admin_notes_url
    rescue => ex
      flash[:error] = _("Note can't deleted.")
    end
  end

end
