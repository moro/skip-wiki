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
      format.js   { render :json => @label_indices }
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

  # PUT /label_indices/1
  # PUT /label_indices/1.xml
  def update
    @label_index = current_note.label_indices.find(params[:id])

    respond_to do |format|
      if @label_index.update_attributes(params[:label_index])
        format.html {
          flash[:notice] = 'LabelIndex was successfully updated.'
          redirect_to note_label_indices_url(current_note)
        }
        format.xml  { head :ok }
        format.js  { head :ok }
      else
        format.html { render :action => "index" }
        format.xml  { render :xml => @label_index.errors, :status => :unprocessable_entity }
      end
    end
  end
end
