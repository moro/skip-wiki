class Admin::PagesController < Admin::ApplicationController
  include PagesModule::PagesUtil
  layout "admin_notes"

  # GET /admin/notes/a_note/pages  
  def index
    @pages = Page.admin(requested_note.id).
                  fulltext(params[:keyword]).
                  authored(*safe_split(params[:authors])).                  
                  scoped(page_order_white_list(params[:order])).
                  paginate(paginate_option(Page))
  end

  def show
    @note = requested_note
    @page = Page.find_by_name(params[:id])
  end

  def edit
    @note = requested_note    
    @page = Page.find_by_name(params[:id])
  end

  def update
    @page = Page.find_by_name(params[:id])
    @page.attributes = params[:page]
    @page.deleted = params[:page][:deleted]

    if @page.save
      flash[:notice] = _("Page was successfully updated.")
      redirect_to admin_note_page_path(requested_note,@page)
    else
      flash[:error] = _("validation error")
      redirect_to edit_admin_note_page_path(requested_note,@page)
    end
  end

  def destroy
    begin
      @page = Page.find_by_name(params[:id])
      @page.destroy
      flash[:notice] = _("Page was deleted successfully")
      redirect_to admin_note_pages_path(requested_note)
    rescue => ex
      flash[:error] = _("Failed to delete a page")
    end
  end
end


