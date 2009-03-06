# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'repim/application'
require 'skip_collabo/op_fixation'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper_method :current_note
  include Repim::Application
  include OpenIdAuthentication
  init_gettext("skip-note") if defined? GetText
  before_filter { Time.zone = "Asia/Tokyo" }
  before_filter :login_required

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '77b5db0ea0fa2d0a22f4fe4a123d699e'

  # See ActionController::Base for details
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password").
  # filter_parameter_logging :password

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

  def access_denied_with_open_id_sso
    if op = SkipCollabo::OpFixation.sso_openid_provider_url
      store_location
      authenticate_with_open_id(op, :method => "get", :return_to=>session_url,
                                    :required => SessionsController.attribute_adapter.keys) do
        access_denied_without_open_id_sso
      end
    else
      access_denied_without_open_id_sso
    end
  end
  alias_method_chain :access_denied, :open_id_sso

  def current_note=(note)
    @__current_note = note
  end

  # Get current note inside of nested controller.
  def current_note
    return nil if @__current_note == :none
    return @__current_note if @__current_note

    scope = logged_in? ? current_user.free_or_accessible_notes : Note.free
    @__current_note = @note || scope.find(params[:note_id]) || :none
    current_note
  end

  def paginate_option(target = Note)
    { :page => params[:page],
      :order => "#{target.quoted_table_name}.updated_at DESC",
      :per_page => params[:per_page] || 10,
    }
  end
end
