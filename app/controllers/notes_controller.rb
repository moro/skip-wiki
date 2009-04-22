require 'skip_embedded/web_service_util/server'

class NotesController < ApplicationController
  before_filter :authenticate, :except => %w[index]
  before_filter :authenticate_with_api_or_login_required, :only => %w[index]
  before_filter :explicit_user_required, :except => %w[index new create dashboard]
  DASHBOARD_ITEM_NUM = 10
  include SkipEmbedded::WebServiceUtil::Server

  layout :select_layout

  # GET /notes
  # GET /notes.xml
  def index
    @notes = accessible.fulltext(params[:fulltext])

    respond_to do |format|
      format.html { @notes = @notes.paginate(paginate_option) }
      format.xml { render :xml => @notes }
      format.js { render :json => @notes.map{|n| note_to_json(n) } }
    end
  end

  def dashboard
    @notes = current_user.free_or_accessible_notes.recent(DASHBOARD_ITEM_NUM + 1)
    @pages = Page.active.scoped(:conditions=>["note_id IN (?)", @notes.map(&:id)]).recent(DASHBOARD_ITEM_NUM + 1)
  end

  # GET /notes/1
  # GET /notes/1.xml
  def show
    @note = current_note

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @note }
    end
  end

  # GET /notes/new
  # GET /notes/new.xml
  def new
    @note = Note.new(:group_backend_type=>"BuiltinGroup", :category=>Category.first)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @note }
    end
  end

  # GET /notes/1/edit
  def edit
    @note = current_note
  end

  # POST /notes
  # POST /notes.xml
  def create
    builder = NoteBuilder.new(current_user, params[:note])
    @note = builder.note

    respond_to do |format|
      begin
        @note.save!
        builder.front_page.save!
        flash[:notice] = _("Note `%{note}' was successfully created.") % {:note => @note.display_name}
        format.html { redirect_to(note_page_path(@note, "FrontPage")) }
        format.xml  { render :xml => @note, :status => :created, :location => @note }
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
        format.html { render :action => "edit" }
        format.xml  { render :xml => @note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /notes/1
  # PUT /notes/1.xml
  def update
    @note = current_note

    respond_to do |format|
      if @note.update_attributes(params[:note])
        flash[:notice] = 'Note was successfully updated.'
        format.html { redirect_to(@note) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /notes/1
  # DELETE /notes/1.xml
  def destroy
    @note = Note.find_by_name(params[:id])
    @note.destroy

    respond_to do |format|
      format.html { redirect_to(notes_url) }
      format.xml  { head :ok }
    end
  end

  private
  def authenticate_with_api_or_login_required
    params[:user].blank? ? authenticate_with_session_or_oauth : check_secret_key
  end

  def note_to_json(note)
    { :display_name=>note.display_name,
      :link_url=>note_path(note),
      :publication_symbols => "note:#{note.id}" }
  end

  def accessible
    if params[:user]
      user = User.find_by_identity_url(params[:user])
    else
      user =current_user
    end
    raise ActiveRecord::RecordNotFound unless user
    user.free_or_accessible_notes
  end

  def explicit_user_required
    self.current_note = current_user.free_or_accessible_notes.find_by_name(params[:id])
    unless current_user.accessible?(current_note)
      render_not_found
    end
  end

  def select_layout
    case params[:action]
    when *%w[index new dashboard] then super
    else "notes"
    end
  end
end
