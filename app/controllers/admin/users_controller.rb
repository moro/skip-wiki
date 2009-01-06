class Admin::UsersController < Admin::ApplicationController
  # GET /admin
  def index
    if params[:keyword].blank?
      @users = User.find(:all)
    else
      @users = User.find(:all, :conditions=>['name like ?', '%'+params[:keyword]+'%'])
    end
  end

  # GET /admin/user/:id/edit
  def edit
    @user = User.find(params[:id])
  end

  # PUT /admin/user/:id
  def update
    @user = User.find(params[:id])
    # FIXME
    @user.admin = params[:admin]
    if @user.update_attributes(params[:user])
      flash[:notice] = _("User update successfully.")
      redirect_to admin_root_path
    else 
      flash[:error] = _("validation error")
      redirect_to :action => 'edit'
    end
  end

private
  def memo str
    logger = Logger.new("#{RAILS_ROOT}/log/development.log")
    logger.info(str)
  end
end
