# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  before_filter :login_required, :except=>%w[new create]

  module AxHandler
    def self.included(base)
      base.hide_action :ax_attributes, :translate_ax_response
    end
    def ax_attributes
      namespace = ["http://axschema.org", "http://schema.openid.net"]
      attributes = %w[/namePerson /namePerson/friendly]
      { :display_name  => namespace.map{|ns| ns + "/namePerson" },
        :name  => namespace.map{|ns| ns + "/namePerson/friendly" },
      }
    end

    def translate_ax_response(fetched)
      returning({}) do |res|
        ax_attributes.each do |k, vs|
          fetched.each{|fk, (fv,_)| res[k] = fv if !fv.blank? && vs.include?(fk) }
        end
      end
    end
  end
  extend AxHandler

  # render new.rhtml
  def new
  end

  def create
    logout_keeping_session!

    if params[:openid_url] && !FixedOp.accept?(params[:openid_url])
      logger.debug("login refused since #{params[:openid_url]} is not member #{FixedOp.servers.inspect}")
      login_failed(params.merge(:openid_url=>openid_url))
    else
      login_with_openid(params[:openid_url])
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = _("You have been logged out.")

    redirect_back_or_default(FixedOp.sso_openid_logout_url || login_path)
  end

  protected
  # Track failed login attempts
  def note_failed_signin(openid_url)
    flash[:error] = _("Couldn't log you in as '#{openid_url}'")
    logger.warn "Failed login for '#{openid_url}' from #{request.remote_ip} at #{Time.now.utc}"
  end

  def login_with_openid(openid_url)
    options = {
      :optional => self.class.ax_attributes.values.flatten,
      :method   => "get",
    }
    authenticate_with_open_id(openid_url, options) do |result, identity_url, personal_data|
      if  result.successful?
        # TODO クエリ最適化
        if account = Account.find_by_identity_url(identity_url)
          logged_in_successful(account.user, session[:return_to] || root_path)
        else
          signup_with_openid(identity_url, personal_data)
        end
      else
        login_failed(params.merge(:openid_url=>identity_url))
      end
    end
  rescue StandardError => ex
    logger.debug{ [ex.message, ex.backtrace].flatten.join("\n") }
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

  def signup_with_openid(identity_url, ax_attributes = {})
    session[:identity_url] = identity_url
    data = self.class.translate_ax_response(ax_attributes)
    session[:user] = data if FixedOp.sso_enabled?
    @user = User.new(data)

    render :template=>"users/new"
  end
end

