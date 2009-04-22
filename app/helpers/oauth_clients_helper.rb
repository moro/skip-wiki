module OauthClientsHelper
  def register_consumer_link(app, action = "/oauth_consumers/new")
    uri = URI.join(@client_application.url, action)
    query = {
      "oauth_consumer[token]" => app.key,
      "oauth_consumer[secret]" => app.secret,
      "oauth_consumer[request_token_url]" => request_token_url,
      "oauth_consumer[access_token_url]" => access_token_url,
      "oauth_consumer[authorize_url]" => authorize_url
    }.map{|k,v| "#{k}=#{u(v)}" }.join("&")
    uri.to_s + "?" + query
  end
end
