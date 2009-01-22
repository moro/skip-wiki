class Admin::GroupsController < Admin::ApplicationController

  def show 
    @group = Group.find(params[:id])  
    @note = @group.owning_note
  end
end
