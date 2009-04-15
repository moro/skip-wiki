class PagesController < ApplicationController
  include PagesModule::PagesUtil
  layout :select_layout
  helper_method :render_hiki
  hide_action :render_hiki

  def index
    @pages = accessible_pages(true).fulltext(params[:keyword]).
                                    labeled(params[:label_index_id]).
                                    authored(*safe_split(params[:authors])).
                                    scoped(page_order_white_list(params[:order]))

    respond_to do |format|
      format.html do
        @pages = @pages.paginate(paginate_option(Page))
        option = params[:note_id].blank? ? {:template => "pages/index", :layout => "application"} :
                                           {:template => "pages/notes_index", :layout => "notes"}
        render(option)
      end
      format.js do
        render :json => @pages.active.find(:all, :include => :note).map{|p| {:page=>page_to_json(p)} }
      end
    end
  end

  def show
    @note = current_note
    @page = accessible_pages.find(params[:id], :include=>:note)
  end

  def new
    @page = current_note.pages.build
    respond_to(:html)
  end

  def create
    @note = current_note
    begin
      ActiveRecord::Base.transaction do
        @page = @note.pages.add(params[:page], current_user)
        @page.save!
      end
      flash[:notice] = _("The page %{page} is successfully created") % {:page=>@page.display_name}
      respond_to do |format|
        format.html{ redirect_to note_page_path(@note, @page) }
      end
    rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
      respond_to do |format|
        format.html{ render :action => "new", :status => :unprocessable_entity }
      end
    end
  end

  def preview
    respond_to do |format|
      format.js do
        render :text=> render_hiki(params[:page][:content_hiki])
      end
    end
  end

  def edit
    @note = current_note
    @page = accessible_pages(true).find(params[:id])
    respond_to(:html)
  end

  def update
    @note = current_note
    begin
      ActiveRecord::Base.transaction do
        @page = accessible_pages.find(params[:id])
        @page.attributes = params[:page].except(:content)
        @page.save!
      end
      respond_to do |format|
        format.html{
          flash[:notice] = _("The page %{page} is successfully updated") % {:page=>@page.display_name}
          redirect_to note_page_path(@note, @page)
        }
        format.js{ head :ok }
      end
    rescue ActiveRecord::RecordInvalid
      respond_to do |format|
        format.html{ render :action => "edit", :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @page = accessible_pages.find(params[:id])
    if @page.logical_destroy
      flash[:notice] = _("Page was deleted successfully")
      redirect_to(note_pages_path(current_note))
    else
      flash[:warn] = _("Failed to delete page.")
      redirect_to(edit_note_page_url(current_note, @page))
    end
  end

  def recovery
    @page = accessible_pages(true).find(params[:id])

    if @page.recover
      flash[:notice] = _("Page was recovered successfully")
      redirect_to(note_pages_path(current_note))
    end
  end

  def render_hiki(content)
    ActionView::Base.white_list_sanitizer.sanitize(HikiDoc.to_xhtml(content, :level =>2))
  end

  private
  def accessible_pages(include_deleted = false, user = current_user, note = nil)
    if params[:note_id] && note ||= current_note
      if include_deleted && user.accessible?(note)
        note.pages
      elsif user.page_editable?(note)
        note.pages.active
      else
        note.pages.active.published
      end
    else
      Page.active.scoped(:conditions => ["#{Page.quoted_table_name}.note_id IN (?)", user.free_or_accessible_notes.all.map(&:id)])
    end
  end

  def select_layout
    case params[:action]
    when *%w[new create] then "notes"
    else "pages"
    end
  end

  def page_to_json(page)
    returning(page.attributes.slice("display_name")) do |json|
      json[:path] = note_page_path(page.note, page)
      json[:updated_at] = page.updated_at.strftime("%Y/%m/%d %H:%M")
      json[:created_at] = page.created_at.strftime("%Y/%m/%d %H:%M")
    end
  end
end
