class Admin::UsersController < Admin::ApplicationController
  layout "admin_users"

  # GET /admin
  def index
    @users = User.fulltext(params[:keyword])
  end

  # GET /admin/user/:id/edit
  def edit
    @user = User.find(params[:id])
  end

  # PUT /admin/user/:id
  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      flash[:notice] = _("User was successfully updated.")
      redirect_to admin_root_path
    else 
      flash[:error] = _("validation error")
      redirect_to :action => 'edit'
    end
  end

end
