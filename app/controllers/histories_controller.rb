require 'diff/lcs'

class HistoriesController < ApplicationController
  layout "notes"

  def index
    @page = current_note.pages.find(params[:page_id])
    @histories = @page.histories
  end

  def show
    @page = current_note.pages.find(params[:page_id])
    @history = @page.histories.detect{|h| h.id == params[:id].to_i }
  end

  def diff
    @page = current_note.pages.find(params[:page_id], :include=>:histories)
    @diffs = @page.diff(params[:from], params[:to])
  end

  def create
    @page = current_note.pages.find(params[:page_id])
    @history = @page.edit(params[:history][:content], current_user)
    if @history.save
      respond_to do |format|
        format.js{ head(:created, :location => note_page_history_path(current_user, @page, @history)) }
      end
    end
  end
end

