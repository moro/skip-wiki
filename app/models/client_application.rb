require 'oauth'
require 'oauth/server'

class ClientApplication < ActiveRecord::Base
  belongs_to :user
  has_many :tokens, :class_name => "OauthToken"
  validates_presence_of :name, :url, :key, :secret
  validates_uniqueness_of :key
  before_validation_on_create :generate_keys
  
  attr_protected :family

  def self.find_token(token_key)
    token = OauthToken.find_by_token(token_key, :include => :client_application)
    if token && token.authorized?
      logger.info "Loaded #{token.token} which was authorized by (user_id=#{token.user_id}) on the #{token.authorized_at}"
      token
    else
      nil
    end
  end
  
  def self.verify_request(request, options = {}, &block)
    begin
      signature = OAuth::Signature.build(request, options, &block)
      logger.info "Signature Base String: #{signature.signature_base_string}"
      logger.info "Consumer: #{signature.send :consumer_key}"
      logger.info "Token: #{signature.send :token}"
      return false unless OauthNonce.remember(signature.request.nonce, signature.request.timestamp)
      value = signature.verify
      logger.info "Signature verification returned: #{value.to_s}"
      value
    rescue OAuth::Signature::UnknownSignatureMethod => e
      logger.info "ERROR"+e.to_s
      false
    end
  end

  def granted_by_service_contract?
    !!family
  end

  def grant_as_family!
    update_attribute(:family, true)
  end
  
  def oauth_server
    @oauth_server ||= OAuth::Server.new("http://your.site")
  end
  
  def credentials
    @oauth_client ||= OAuth::Consumer.new(key, secret)
  end
    
  def create_request_token
    RequestToken.create :client_application => self
  end

  def publish_access_token(user)
    raise ArgumentError unless granted_by_service_contract?

    req_token = create_request_token
    req_token.authorize!(user)
    req_token.exchange!
  end

protected
  
  def generate_keys
    @oauth_client = oauth_server.generate_consumer_credentials
    self.key = @oauth_client.key
    self.secret = @oauth_client.secret
  end
end
