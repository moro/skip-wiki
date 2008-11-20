class PagesController < ApplicationController
  layout "notes"
  def index
    pages = current_note.pages
    pages = pages.fulltext(params[:keyword]) unless params[:keyword].blank?

    @pages = pages.scoped(:order=>"pages.updated_at DESC").find(:all)
  end

  def show
    @note = current_note
    @page = @note.pages.find_or_initialize_by_name(params[:id], :include=>:note)

    if @page.new_record?
      flash[:notice] = _("Create new page '%{page}'.") % {:page=>@page.name}
      respond_to do |format|
        format.html do
          render :action=>"edit", :status=>:not_found
        end
      end
    else
      respond_to do |format|
        format.html
      end
    end
  end

  def new
    @page = current_note.pages.build
    respond_to do |format|
      format.html do
        render :action=>"edit"
      end
    end
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
    rescue ActiveRecord::RecordNotSaved
      respond_to do |format|
        format.html{ render :action => "edit", :status => :unprocessable_entity }
      end
    end
  end

  def preview
    respond_to do |format|
      format.js do
        # FIXME
        render :text=>HikiDoc.to_xhtml(params[:page][:content], :level=>2), :type=>"text/html"
      end
    end
  end

  def edit
    @note = current_note
    @page = @note.pages.find(params[:id])
  end

  def update
    @note = current_note
    begin
      ActiveRecord::Base.transaction do
        @page = @note.pages.find(params[:id])
        @page.attributes = params[:page].except(:content)
        @page.save!
      end
      flash[:notice] = _("The page %{page} is successfully updated") % {:page=>@page.display_name}
      respond_to do |format|
        format.html{ redirect_to note_page_path(@note, @page) }
      end
    rescue ActiveRecord::RecordInvalid
      respond_to do |format|
        format.html{ render :action => "edit", :status => :unprocessable_entity }
      end
    end
  end

  private
  def render_new_page_form(page = @page)
  end

end
