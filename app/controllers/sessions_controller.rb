# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  before_filter :login_required, :except=>%w[new create]

  # render new.rhtml
  def new
  end

  def create
    logout_keeping_session!

    if params[:openid_url] && !FixedOp.accept?(params[:openid_url])
      login_failed(params.merge(:openid_url=>openid_url))
    else
      login_with_openid(params[:openid_url])
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = _("You have been logged out.")
    redirect_back_or_default(login_path)
  end

  protected
  # Track failed login attempts
  def note_failed_signin(openid_url)
    flash[:error] = _("Couldn't log you in as '#{openid_url}'")
    logger.warn "Failed login for '#{openid_url}' from #{request.remote_ip} at #{Time.now.utc}"
  end

  def login_with_openid(openid_url)
    authenticate_with_open_id(openid_url) do |result, identity_url, sreg|
      if  result.successful?
        # TODO クエリ最適化
        if account = Account.find_by_identity_url(identity_url)
          logged_in_successful(account.user, session[:return_to] || root_path)
        else
          signup_with_openid(identity_url, sreg)
        end
      else
        login_failed(params.merge(:openid_url=>identity_url))
      end
    end
  rescue StandardError => ex
    logger.debug(ex)
    login_failed(params.merge(:openid_url=>openid_url))
  end

  def logged_in_successful(user, redirect=root_path)
    reset_session
    self.current_user = user
    new_cookie_flag = (params[:remember_me] == "1")
    handle_remember_cookie! new_cookie_flag
    flash[:notice] = _("Logged in successfully")
    redirect_back_or_default(redirect)
  end

  # log login faulure. and re-render sessions/new
  def login_failed(assigns=params)
    note_failed_signin(assigns[:openid_url])
    @login       = assigns[:login]
    @openid_url  = assigns[:openid_url]
    @remember_me = assigns[:remember_me]

    render :action => 'new'
  end

  def signup_with_openid(identity_url, sreg=nil)
    @account = Account.new(:identity_url => session[:identity_url] = identity_url)
    render :template=>"accounts/new"
  end
end

