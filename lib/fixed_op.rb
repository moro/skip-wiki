require 'openid'

class FixedOp
  cattr_accessor :servers, :sso_openid_provider_url

  def self.accept?(claimed_url)
    servers.empty? || new(*servers).accept?(claimed_url)
  end

  def self.sso_enabled?
    @@config && !@@config["disabled"]
  end

  def self.sso_openid_logout_url
    URI.join(sso_openid_provider_url + "logout").to_s if sso_openid_provider_url
  end

  @@config = INITIAL_SETTINGS[:fixed_op]
  if sso_enabled?
    @@servers = @@config["acceptable_op_urls"]
    @@sso_openid_provider_url = @@config["fixed_openid_server_url"]
  else
    @@servers, @@sso_openid_provider_url = [], nil
  end

  def initialize(*allowed)
    @available_servers = allowed
  end

  def accept?(claimed_url)
    begin
      _, services = OpenID.discover claimed_url
      services.any?{|s| @available_servers.include?(s.server_url) }
    rescue OpenID::DiscoveryFailure => why
      ::OpenID::Util.logger.error "FixedOp discovery failed: #{why.message}"
      false
    end
  end
end

