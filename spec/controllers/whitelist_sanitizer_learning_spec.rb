require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationController, "HTML::WhiteListSanitizer" do
  before do
    @sanitizer = HTML::WhiteListSanitizer.new
    allow = HTML::WhiteListSanitizer.allowed_attributes.dup.add("style")
    @option = {:attributes => allow}
  end
  it "タグを含まないテキストは変わらないこと" do
    @sanitizer.sanitize("hoge", @option).should == "hoge"
  end

  it "style属性にfont-size:largeを指定した場合、そのままであること" do
    str = "<span style=\"font-size: large;\">hoge</span>"
    @sanitizer.sanitize(str, @option).should == str
  end

  it "style属性にfont-size: large; expression: hogeの場合、expressionが取り除かれること" do
    str = "<span style=\"font-size: large; expression: 'hoge';\">hoge</span>"
    @sanitizer.sanitize(str, @option).should == "<span style=\"font-size: large;\">hoge</span>"
  end

  it "style属性にfont-size: large; expression: alert('hoge')の場合、valueが不正なためにすべてのスタイルが除かれること" do
    str = "<span style=\"font-size: large; expression: 'alert(\'hoge\')';\">hoge</span>"
    @sanitizer.sanitize(str, @option).should == "<span style=\"\">hoge</span>"
  end

  it "style属性にfont-size: large; ｅｘｐｒｅｓｓｉｏｎ: hogeの場合、すべて取り除かれること" do
    str = "<span style=\"font-size: large; ｅｘｐｒｅｓｓｉｏｎ: 'hoge';\">hoge</span>"
    @sanitizer.sanitize(str, @option).should == "<span style=\"\">hoge</span>"
  end

  it "オプションを指定しない場合にはstyleタグは相変わらず取り除かれること" do
    str = "<span style=\"font-size: large;\">hoge</span>"
    @sanitizer.sanitize(str).should == "<span>hoge</span>"
  end
end

