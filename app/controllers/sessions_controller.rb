# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  before_filter :login_required, :except=>%w[new create]

  # render new.rhtml
  def new
  end

  def create
    logout_keeping_session!
    if using_open_id?
      login_with_openid(params[:openid_url])
    else
      login_with_password(params[:login], params[:password])
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(login_path)
  end

  protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end

  def login_with_openid(openid_url)
    authenticate_with_open_id(openid_url) do |result, identity_url, sreg|
      if result.successful?
        # TODO クエリ最適化
        if account = Account.find_by_identity_url(identity_url)
          logged_in_successful(account.user, session[:return_to])
        else
          signup_with_openid(identity_url, sreg)
        end
      else
        login_failed(params.merge(:openid_url=>identity_url))
      end
    end
  end

  def login_with_password(login, password)
    if account = Account.authenticate(login, password)
      logged_in_successful(account.user)
    else
      login_failed
    end
  end

  def logged_in_successful(user, redirect="/")
    reset_session
    self.current_user = user
    new_cookie_flag = (params[:remember_me] == "1")
    handle_remember_cookie! new_cookie_flag
    flash[:notice] = "Logged in successfully"
    redirect_back_or_default(redirect)
  end

  # log login faulure. and re-render sessions/new
  def login_failed(assing_params=params)
    note_failed_signin
    @login       = assing_params[:login]
    @openid_url  = assing_params[:openid_url]
    @remember_me = assing_params[:remember_me]

    flash[:notice] = _("Logged Failed")
    render :action => 'new'
  end

  def signup_with_openid(identity_url, sreg=nil)
    @account = Account.new(:identity_url => session[:identity_url] = identity_url)
    render :template=>"accounts/new"
  end
end
