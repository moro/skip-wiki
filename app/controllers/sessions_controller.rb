# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  before_filter :login_required, :except=>%w[new create]
  before_filter :specified_op_is_accesptable, :only => %w[create]

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

  def specified_op_is_accesptable
    if params[:openid_url] && !SkipCollabo::OpFixation.accept?(params[:openid_url])
      logger.debug("login refused since #{params[:openid_url]} is not member #{SkipCollabo::OpFixation.servers.inspect}")
      login_failed(params.merge(:openid_url=>params[:openid_url]))
    else
      true
    end
  end

  def create
    logout_keeping_session!
    options = { :optional => self.class.ax_attributes.values.flatten,
                :method   => "get" }

    authenticate_with_open_id(params[:openid_url], options) do |result, identity_url, personal_data|
      if result.successful?
        authenticated(identity_url, personal_data)
      else
        login_failed(params.merge(:openid_url=>identity_url))
      end
    end
  rescue StandardError => ex
    logger.debug{ [ex.message, ex.backtrace].flatten.join("\n") }
    login_failed(params)
  end

  def destroy
    logout_killing_session!
    flash[:notice] = _("You have been logged out.")

    redirect_back_or_default(SkipCollabo::OpFixation.sso_openid_logout_url || login_path)
  end

  protected
  def authenticated(identity_url, personal_data = {})
    if user = find_user_by_identity_url(identity_url)
      login_successfully(user, personal_data)
      redirect_back_or_default(session[:return_to] || root_path)
    else
      signup_with_openid(identity_url, personal_data)
      render :template=>"users/new"
    end
  end

  # ovverride
  def find_user_by_identity_url(identity_url)
    account = Account.find_by_identity_url(identity_url)
    account && account.user
  end

  def sync_user_data(user, personal_data = {})
    data = self.class.translate_ax_response(personal_data)
    account.user.update_attributes!(data.slice(:display_name))
    flash[:notice] = _("Successfully synchronized your display name with OP's")
  end

  def login_successfully(user, personal_data)
    sync_user_data(user, personal_data) if SkipCollabo::OpFixation.sso_enabled?

    reset_session
    self.current_user = user
    new_cookie_flag = (params[:remember_me] == "1")
    handle_remember_cookie! new_cookie_flag
    flash[:notice] ||= _("Logged in successfully")
  end

  # log login faulure. and re-render sessions/new
  def login_failed(assigns=params)
    flash[:error] = _("Couldn't log you in as '#{assigns[:openid_url]}'")
    logger.warn "Failed login for '#{assigns[:openid_url]}' from #{request.remote_ip} at #{Time.now.utc}"

    @login       = assigns[:login]
    @openid_url  = assigns[:openid_url]
    @remember_me = assigns[:remember_me]

    render :action => 'new'
  end

  def signup_with_openid(identity_url, ax_attributes = {})
    session[:identity_url] = identity_url
    data = self.class.translate_ax_response(ax_attributes)
    session[:user] = data if SkipCollabo::OpFixation.sso_enabled?
    @user = User.new(data)
  end
end

