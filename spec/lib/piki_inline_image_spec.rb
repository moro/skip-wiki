require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'piki_inline_image'

describe PikiInlineImage do
  before do
    @piki = PikiInlineImage.new
    @src = "image('/notes/foobar/attachments/123?position=inline')"
  end

  it "accept" do
    @piki.should be_accept(@src)
  end

  it "reject many bad pattern" do
    @piki.should satisfy do |piki|
      bad_sources = [
        "image('/path/to/any/whare')",
        "image('<script></script>hoge', 12345a)",
        "image('http://malicious.example.com/virus.gif')",
        "image('/notes/foobar/attachments/123?position=inline\' onclick')"
      ].all?{|src| not piki.accept?(src) }
    end
  end

  it "inline_plugin" do
    @piki.inline_plugin(@src).should ==
      "<img class='piki' src='/notes/foobar/attachments/123?position=inline' />"
  end

  it "block_plugin" do
    @piki.block_plugin(@src).should ==
      "<p class='piki image'><img class='piki' src='/notes/foobar/attachments/123?position=inline' /></p>"
  end
end

