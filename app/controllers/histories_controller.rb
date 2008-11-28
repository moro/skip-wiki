require 'diff/lcs'

class HistoriesController < ApplicationController
  layout lambda{|c|
    case c.params[:action]
    when *%w[dummy] then "notes"
    else "application"
    end
  }

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

  def new
    @page = current_note.pages.find(params[:page_id])
  end

  def create
    @page = current_note.pages.find(params[:page_id])
    @history = @page.edit(params[:history][:content], current_user)
    if @history.save
      respond_to do |format|
        format.js{ head(:created, :location => note_page_history_path(current_note, @page, @history)) }
      end
    else
      errors = [@history, @history.content].map{|m| m.errors.full_messages }.flatten

      respond_to do |format|
        format.js{ render(:json => errors, :status=>:unprocessable_entity) }
      end
    end
  end

  def update
    @page = current_note.pages.find(params[:page_id])
    @history = @page.histories.find(params[:id], :include=>:content)
    if @history.content.data != params[:history][:content]
      @history.content.data = params[:history][:content]
      ActiveRecord::Base.transaction do
        @history.content.save!
        @history.update_attributes!(:user => current_user, :updated_at => Time.now.utc)
      end
    end
    respond_to do |format|
      format.js{ head(:ok) }
    end
  end
end

