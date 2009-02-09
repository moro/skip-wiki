class UsersController < ApplicationController
  before_filter :login_required, :except=>%w[new create]
  before_filter :cant_modify_under_sso, :only => %w[edit update]

  def create
    logout_keeping_session!
    @user = User.new(FixedOp.sso_enabled? ? session[:user] : params[:user])
    @user.account = Account.new{|a| a.identity_url = session[:identity_url] }
    if @user.save
      reset_session
      session[:identity_url] = nil

      self.current_user = @user
      redirect_back_or_default(root_path)
      flash[:notice] = _("Thanks for signing up!.")
    else
      flash[:error]  = _("We couldn't set up that account, sorry.  Please try again.")
      render :action => 'new'
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = current_user
    head(:forbidden) unless @user.to_param == params[:id]
  end

  private
  def cant_modify_under_sso
    if FixedOp.sso_enabled?
      flash[:warn] = _("Cannot modify user information manually. Logout and login again to update.")
      redirect_to(:back) rescue redirect_to(root_path)
    else
      true
    end
  end
end
