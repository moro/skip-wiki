class Admin::PagesController < Admin::ApplicationController

  # GET /admin/notes/a_note/pages  
  def index
    @pages = Page.find_all_by_note_id(requested_note.id)
  end

  def show
    @note = requested_note
    @page = Page.find(params[:id])
  end

  def edit
    @note = requested_note    
    @page = Page.find(params[:id])
  end

  def update
    @page = Page.find(params[:id])
    if @page.update_attributes(params[:page])
      flash[:notice] = _("Page was successfully updated.")
      redirect_to admin_note_page_path(requested_note,@page)
    else
      flash[:error] = _("validation error")
      redirect_to edit_admin_note_page_path(requested_note,@page)
    end
  end

  def destroy
    begin
      @page = Page.find(params[:id])
      @page.destroy
      flash[:notice] = _("Page was deleted successfully")
      redirect_to admin_note_pages_path(requested_note)
    rescue => ex
      flash[:error] = _("Failed to delete a page")
    end
  end

private
  def requested_note
    @note = Note.find(params[:note_id])
  end

end
