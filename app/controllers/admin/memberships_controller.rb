class Admin::MembershipsController < ApplicationController

  # TODO 諸橋さんのこぴっただけでよく理解していない 
  def create
    group = current_user.groups.find(params[:group_id])
    queries = params[:memberships].map{|_,q| q }
    valid_params = queries.select{|q| q[:enabled] && Integer(q[:group_id]) == group.id }
    begin
      ActiveRecord::Base.transaction do
        ids = (valid_params.map{|q| Integer(q[:user_id]) } << current_user.id).uniq
        group.user_ids = ids
      end
      flash[:notice] = _("Memberships was successfully updated")
      redirect_to(admin_group_path(group))
    rescue ActiveRecord::RecordNotSaved
      render :template => "admin/groups/show"
    end
  end

private
  def requested_user
    @user ||= User.find(params[:user_id])
  end
end
