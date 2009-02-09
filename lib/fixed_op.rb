require 'openid'

class FixedOp
  def self.servers=(servers)
    @servers = Array(servers)
  end
  def self.servers
    @servers ||= (defined? ACCEPTABLE_OP_URLS) ?  Array(ACCEPTABLE_OP_URLS) : []
  end

  def self.accept?(claimed_url)
    servers.empty? || new(*servers).accept?(claimed_url)
  end

  @@sso_openid_provider_url = (defined? FIXED_OPENID_SERVER_URL) ? FIXED_OPENID_SERVER_URL : nil
  def self.sso_enabled?
    !!sso_openid_provider_url
  end

  def self.sso_openid_provider_url
    @@sso_openid_provider_url
  end

  def self.sso_openid_logout_url
    URI.join(sso_openid_provider_url + "logout").to_s if sso_openid_provider_url
  end

  def self.sso_openid_provider_url=(url)
    @@sso_openid_provider_url = url
  end

  def initialize(*allowed)
    @available_servers = allowed
  end

  def accept?(claimed_url)
    begin
      _, services = OpenID.discover claimed_url
      services.any?{|s| @available_servers.include?(s.server_url) }
    rescue OpenID::DiscoveryFailure => why
      ::OpenID::Util.logger "FixedOp discovery failed: #{why.message}"
      false
    end
  end
end

