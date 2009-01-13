class Admin::NotesController < Admin::ApplicationController

  # GET 
  def index
    if params[:keyword].blank?
      @notes = Note.find(:all)
    else
      @notes = Note.find(:all, :conditions=>['display_name like ?', '%'+params[:keyword]+'%'])
    end
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
    # TODO 髢｢騾｣繝��繝悶Ν縺ｯdestroy縺ｧ蜑企勁縺励※縺上ｌ縺ｪ縺九▲縺溘°縺ｩ縺�°隲ｸ讖九＆繧薙↓閨槭￥
    begin
      ActiveRecord::Base.transaction do
        @note = Note.find(params[:id])
        @note.destroy
        flash[:notice] = "Success to delete a note"
        redirect_to admin_notes_path
      end
    rescue => ex
      flash[:error] = "Failed to delete a note"
    end
  end

private
  def memo str
    logger = Logger.new("#{RAILS_ROOT}/log/development.log")
    logger.info str
  end 

end
