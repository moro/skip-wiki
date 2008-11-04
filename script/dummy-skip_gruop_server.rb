#!/usr/bin/env ruby
# vim:set fileencoding=utf-8 filetype=ruby
# $KCODE = 'u'

require 'rubygems'
require 'activesupport'
require 'webrick/httpserver'

SkipGroup = Struct.new(:name, :display_name, :gid, :updated_at) do
  def to_xml(*args)
    attributes.to_xml(*args)
  end

  def attributes
    Hash[*members.zip(values).flatten]
  end
end

class SkipGroupServlet < WEBrick::HTTPServlet::AbstractServlet
  DEFAULT_GROPS = [
    SkipGroup.new("SKIP", "SKIPグループ", "gid:12345", Time.local(2008,10,01, 9,00)),
    SkipGroup.new("WIKI", "SKIP-Wiki", "gid:23456", Time.local(2008,10,10, 9,00)),
  ].freeze

  def dispatch(req, res)
    ret = case req.path
          when %r!/user/([A-Za-z][A-Za-z0-9]+)/groups.xml\Z!
            user_group_servlet($1, req, res)
          else
            ["Not Found (bad path?)", "text/plain", "404"]
          end
    res.body = ret[0]
    res.content_type = ret[1] || "application/xml"
    res.status = ret[2] || "200"
  end
  alias service dispatch

  private

  def user_group_servlet(user, req, res)
    groups = DEFAULT_GROPS + [
      SkipGroup.new(user+"_private", "#{user}の自分用グループ", "gid:98765#{user}", Time.now),
    ]
    [groups.to_xml(:root=>"groups")]
  end
end

if __FILE__ == $0
  s = WEBrick::HTTPServer.new(:Port=>10080)
  s.mount "/", SkipGroupServlet
  trap("INT"){s.shutdown}
  s.start
end

