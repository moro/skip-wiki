class AccountsController < ApplicationController
  skip_before_filter :login_required
  def new
    @account = Account.new
  end

  def create
    identity_url = session[:identity_url]
    logout_keeping_session!
    @account = Account.new(params[:account])
    @account.identity_url = identity_url
    success = @account && @account.save
    if success && @account.errors.empty?
      reset_session

      self.current_user = @account.user
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end

  end
end
