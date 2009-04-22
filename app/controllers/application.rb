# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'repim/application'
require 'skip_embedded/open_id_sso/authentication'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper_method :current_note

  include Repim::Application
  include SkipEmbedded::OpenIdSso::Authentication

  init_gettext("skip-note") if defined? GetText
  before_filter { Time.zone = "Asia/Tokyo" }

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '77b5db0ea0fa2d0a22f4fe4a123d699e'

  rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found

  layout :select_layout

  private
  def select_layout
    "application"
  end

  def render_not_found(e = nil)
    e.backtrace.each{|m| logger.debug m } if e
    render :template => "shared/not_found", :status => :not_found, :layout => false
  end

  def current_note=(note)
    @__current_note = note
  end

  # Get current note inside of nested controller.
  def current_note
    return nil if @__current_note == :none
    return @__current_note if @__current_note

    scope = logged_in? ? current_user.free_or_accessible_notes : Note.free
    @__current_note = @note || scope.find_by_name(params[:note_id]) || :none
    current_note
  end

  def authenticate_with_session_or_oauth
    if oauthenticate
      authenticate_with_oauth(:loaded)
    else
      authenticate
    end
  end

  def authenticate_with_oauth(current_token_loaded = false)
    if (current_token_loaded || oauthenticate) &&
       (token = ClientApplication.find_token(current_token.token))
      self.current_user = token.user
      return true
    else
      logger.info "failed oauthenticate"
      invalid_oauth_response
    end
  end

  def paginate_option(target = Note)
    { :page => params[:page],
      :order => "#{target.quoted_table_name}.updated_at DESC",
      :per_page => params[:per_page] || 10,
    }
  end

  # Override Repim's to translate message and specify signup layout.
  def access_denied_without_open_id_sso(message = nil)
    store_location
    flash[:error] = _("Login required.")
    render :template => "sessions/new", :layout => "application", :status => :unauthorized
  end
end
