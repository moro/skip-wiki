class LabelIndicesController < ApplicationController
  layout "notes"

  # GET /label_indices
  # GET /label_indices.xml
  def index
    @note = current_note
    @label_indices = @note.label_indices

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @label_indices }
    end
  end

  # GET /label_indices/1
  # GET /label_indices/1.xml
  def show
    @note = current_note
    @label_index = @note.label_indices.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @label_index }
    end
  end

  # POST /label_indices
  # POST /label_indices.xml
  def create
    @note = current_note
    @label_index = @note.label_indices.build(params[:label_index])

    respond_to do |format|
      if @label_index.save
        flash[:notice] = 'LabelIndex was successfully created.'
        format.html { redirect_to note_label_indices_url(@note) }
        format.xml  { render :xml => @label_index, :status => :created, :location => @label_index }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @label_index.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /label_indices/1
  # PUT /label_indices/1.xml
  def update
    @label_index = current_note.label_indices.find(params[:id])

    respond_to do |format|
      if @label_index.update_attributes(params[:label_index])
        flash[:notice] = 'LabelIndex was successfully updated.'
        format.html { redirect_to note_label_indices_url(current_note) }
        format.xml  { head :ok }
      else
        format.html { render :action => "index" }
        format.xml  { render :xml => @label_index.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /label_indices/1
  # DELETE /label_indices/1.xml
  def destroy
    @label_index = current_note.label_indices.find(params[:id])
    @label_index.destroy

    respond_to do |format|
      format.html { redirect_to(note_label_indices_url(current_note)) }
      format.xml  { head :ok }
    end
  end

  def next
    @label_index = current_note.label_indices.find(params[:id])
    @page = @label_index.pages.next(params[:pivot])
    redirect_to_page_or_back(
      _("This is the last page in %{label}.") % {:label => @label_index.display_name}
    )
  end

  def prev
    @label_index = current_note.label_indices.find(params[:id])
    @page = @label_index.pages.previous(params[:pivot])
    redirect_to_page_or_back(
      _("This is the first page in %{label}.") % {:label => @label_index.display_name}
    )
  end

  private
  def redirect_to_page_or_back(message)
    if @page
      redirect_to(note_page_path(current_note, @page))
    else
      flash[:notice] = message
      redirect_to :back
    end
  end
end
