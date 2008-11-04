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
end

