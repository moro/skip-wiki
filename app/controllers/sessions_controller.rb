require 'repim/relying_party'
# This controller handles the login/logout function of the site.
module SkipCollabo
  module OpenIdSso
    def self.included(controller)
      controller.before_filter :specified_op_is_accesptable, :only => %w[create]
    end

    def after_login_path
      session[:return_to] || root_path
    end

    def after_logout_path
      SkipCollabo::OpFixation.sso_openid_logout_url || login_path
    end

    def login_successfully(user, personal_data)
      if SkipCollabo::OpFixation.sso_enabled?
        data = attribute_adapter.adapt(personal_data)
        user.update_attributes!(data.slice(:display_name))
        flash[:notice] = _("Successfully synchronized your display name with OP's")
      end
      super
    end

    def signup(identity_url, personal_data = {})
      session[:user] = attribute_adapter.adapt(personal_data) if SkipCollabo::OpFixation.sso_enabled?
      super
    end

    def specified_op_is_accesptable
      if params[:openid_url] && !SkipCollabo::OpFixation.accept?(params[:openid_url])
        logger.debug("login refused since #{params[:openid_url]} is not member #{SkipCollabo::OpFixation.servers.inspect}")
        login_failed(params.merge(:openid_url=>params[:openid_url]))
      else
        true
      end
    end
  end
end

class SessionsController < ApplicationController
  include Repim::RelyingParty
  include SkipCollabo::OpenIdSso
  before_filter :login_required, :except=>%w[new create]

  use_attribute_exchange(["http://axschema.org", "http://schema.openid.net"],
                         :display_name => "/namePerson", :name => "/namePerson/friendly" )

end

