class Admin::GroupsController < Admin::ApplicationController
  layout "admin_notes"

  def show 
    @group = Group.find(params[:id])  
    @note = @group.owning_note
  end
end
