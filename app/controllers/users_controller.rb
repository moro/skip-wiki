class UsersController < ApplicationController
  before_filter :login_required, :except=>%w[new create]

  def create
    logout_keeping_session!
    @user = User.new(params[:user])
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
end
