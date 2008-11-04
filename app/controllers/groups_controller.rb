class GroupsController < ApplicationController
  layout "notes", :only => %w[show]

  def show
    @group = Group.find(params[:id])
    self.current_note = @group.owning_note
  end
end
