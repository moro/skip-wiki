class Admin::PagesController < Admin::ApplicationController

  # GET /admin/notes/a_note/pages  
  def index
    memo(requested_note.id)
    @pages = Page.find_by_note_id(requested_note.id)
  end

private 
  def memo str
    logger = Logger.new("#{RAILS_ROOT}/log/development.log")
    logger.info("------------------------------")
    logger.info(str)
    logger.info("------------------------------")
  end

  def requested_note
    @note = Note.find(params[:note_id])
  end
end
