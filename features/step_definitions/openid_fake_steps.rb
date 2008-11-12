require 'net/http'

open_id_step = Proc.new do |n|
  visits(login_path)
  doc = Nokogiri::HTML(response_body)
  f = doc.css("form").detect{|form| !form.css("input[name=openid_url]").empty? }
  post(f["action"], :openid_url => n)

  oid_auth = URI(response.headers["Location"])
  oid_authorized_query = nil
  Net::HTTP.start(oid_auth.host, oid_auth.port) do |h|
    res = h.get(oid_auth.request_uri)

    auth_form = Nokogiri::HTML(res.body).css("form").first

    auth_req = Net::HTTP::Post.new(auth_form["action"])
    auth_req["cookie"] = res["set-cookie"]
    auth_req.body = "yes=yes"

    auth_res = h.request(auth_req)
    oid_authorized_query = auth_res["location"]
  end

  visits( URI(oid_authorized_query).request_uri )
end

Given(/\AI log in with OpenId "(.*)"$/, &open_id_step)
Given(/\AOpenId "(.*)"でログインする$/, &open_id_step)

