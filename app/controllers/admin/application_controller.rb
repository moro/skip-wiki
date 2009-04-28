class Admin::ApplicationController < ApplicationController
  before_filter :require_admin
  
  def require_admin
    unless current_user.admin?
      redirect_to root_url
      return false
    end
  end

  def requested_note
    @note = Note.find_by_name(params[:note_id])
  end
end
