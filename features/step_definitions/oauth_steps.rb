require 'rss'

module OAuthStepHelper
  def get_consumer(application = @application)
    OAuth::Consumer.new(application.key, application.secret,
                        :site => application.url,
                        :authorize_path => authorize_path,
                        :request_token_path => request_token_path,
                        :access_token_path => access_token_path)
  end

  def parse_response(body = response.body)
    CGI.parse(body).inject({}){|h,(k,v)| h.merge(k.to_sym => v.first)}
  end

  def assign_authorization_header(consumer, &sign_proc)
    http_req = consumer.instance_eval(&sign_proc)
    header("Authorization", http_req["Authorization"])
  end
end
include OAuthStepHelper

When /^OAuthコンシューマー登録画面を表示している$/ do
  visit new_oauth_client_path
end

When /^SKIPファミリのコンシューマ"([^\"]*)"を登録する$/ do |name|
  @application = ClientApplication.create :name => name, :url => "http://www.example.com", :callback_url => "http://extsite.com/callback"
  @application.grant_as_family!
end

When /^"([^\"]*)"のアクセストークンを取得する$/ do |name|
  visit "/"

  @application = ClientApplication.find_by_name(name)
  consumer = get_consumer(@application)

  assign_authorization_header(consumer){ create_signed_request(http_method, request_token_path) }
  visit(consumer.request_token_path, :post)

  req_token_param = parse_response(response.body)
  req_token = OAuth::RequestToken.new(consumer, req_token_param[:oauth_token], req_token_param[:oauth_token_secret])
  visit req_token.authorize_url

  authorized_req_token = URI(response.headers["Location"]).query
  visit [access_token_path, authorized_req_token].join("?")

  access_token_params = parse_response
  @access_token = OAuth::AccessToken.from_hash(consumer, access_token_params)
end

When /^OAuth経由でノートのRSSを取得できること$/ do
  assign_authorization_header(get_consumer){ create_signed_request(:get, "/notes.rss", @access_token) }

  visit "/notes.rss"
end

Then /^(\d+)件のアイテムがあること/ do |num|
  RSS::Parser.parse(response.body).should have(num.to_i).items
end

