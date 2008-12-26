class NotesController < ApplicationController
  layout "application"
  before_filter :explicit_user_required, :except => %w[index new create]

  # GET /notes
  # GET /notes.xml
  def index
    accessible = logged_in? ? current_user.accessible(Note) : Note.public
    @notes = accessible.fulltext(params[:fulltext]).recent(params[:max] || 10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @notes }
      format.js{
        data = @notes.map{|n| {:display_name=>n.display_name, :url=>note_path(n)} }
        render :json => data
      }
    end
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
    @note = Note.new(:group_backend_type=>"BuiltinGroup")

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
    @note = Note.find(params[:id])
    @note.destroy

    respond_to do |format|
      format.html { redirect_to(notes_url) }
      format.xml  { head :ok }
    end
  end

  private
  def explicit_user_required
    self.current_note = current_user.accessible(Note).find(params[:id])
    unless current_note.accessible?(current_user)
      render_not_found
    end
  end
end
