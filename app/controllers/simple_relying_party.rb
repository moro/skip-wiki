module SimpleRelyingParty
  class AxAttributeAdapter
    attr_reader :rule, :necessity
    # TODO refactor
    def initialize(prefixes, propaties)
      @rule = {}
      @necessity = :optional
      propaties.each do |model_attr, property|
        @rule[model_attr] = prefixes.map{|px| px + property }
      end
    end

    def keys
      rule.values.flatten
    end

    def required!
      @necessity = :required
    end

    def adapt(fetched)
      returning({}) do |res|
        rule.each do |k, vs|
          fetched.each{|fk, (fv,_)| res[k] = fv if !fv.blank? && vs.include?(fk) }
        end
      end
    end
  end

  def self.included(base)
    base.cattr_accessor :attribute_adapter
    base.extend(ClassMethods)
  end

  module ClassMethods
    def use_attribute_exchange(prefixes, propaties)
      self.attribute_adapter = AxAttributeAdapter.new(prefixes, propaties)
    end
  end

  # render new.rhtml
  def new
  end

  def create
    logout_keeping_session!
    options = { :method => "get" }
    options[attribute_adapter.necessity] = attribute_adapter.keys

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

    redirect_back_or_default(after_logout_path)
  end

  private
  def authenticated(identity_url, personal_data = {})
    if user = find_user_by_identity_url(identity_url)
      login_successfully(user, personal_data)
      redirect_back_or_default(session[:return_to] || root_path)
    else
      signup_with_openid(identity_url, personal_data)
      render :template=>"users/new"
    end
  end

  def find_user_by_identity_url(identity_url)
    User.find_by_identity_url(identity_url)
  end

  def login_successfully(user, personal_data)
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

  def signup_with_openid(identity_url, ax = {})
    session[:identity_url] = identity_url
    @user = User.new( attribute_adapter.adapt(ax) )
  end

  def after_login_path; root_path ; end
  def after_logout_path; login_path ; end
end

