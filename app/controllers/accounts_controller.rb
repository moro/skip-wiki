class AccountsController < ApplicationController
  skip_before_filter :login_required
  def new
    @account = Account.new
  end

  def create
    identity_url = session[:identity_url]
    logout_keeping_session!
    @account = Account.new(params[:account])
    @account.login = params[:user][:name] # workaround
    @account.identity_url = identity_url
    @account.build_user(params[:user])
    success = @account.valid? && @account.user.valid?

    if success && @account.save
      reset_session

      self.current_user = @account.user
      redirect_back_or_default(root_path)
      flash[:notice] = _("Thanks for signing up!.")
    else
      flash[:error]  = _("We couldn't set up that account, sorry.  Please try again.")
      render :action => 'new'
    end

  end
end
