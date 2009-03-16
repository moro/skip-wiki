require 'repim/relying_party'
require 'skip_embedded/open_id_sso/session_management'

# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  include OpenIdAuthentication
  include Repim::RelyingParty
  include SkipEmbedded::OpenIdSso::SessionManagement
  before_filter :authenticate, :except=>%w[new create]

  use_attribute_exchange(["http://axschema.org", "http://schema.openid.net"],
                         :display_name => "/namePerson", :name => "/namePerson/friendly" )

end

