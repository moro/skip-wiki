require 'repim/relying_party'
require 'skip_collabo/open_id_sso'

# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  include OpenIdAuthentication
  include Repim::RelyingParty
  include SkipCollabo::OpenIdSso::SessionManagement
  before_filter :login_required, :except=>%w[new create]

  use_attribute_exchange(["http://axschema.org", "http://schema.openid.net"],
                         :display_name => "/namePerson", :name => "/namePerson/friendly" )

end

