class GroupsController < ApplicationController
  def show
    @group = Group.find(params[:id])
    self.current_note = @group.owning_note
  end
end
