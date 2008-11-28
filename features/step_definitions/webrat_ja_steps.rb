# Commonly used webrat steps
# http://github.com/brynary/webrat

When /言語は"(.*)"/ do |lang|
  header("ACCEPT_LANGUAGE", lang)
end

When /^"(.*)"ボタンをクリックする$/ do |button|
  clicks_button(button)
end

When /^"(.*)"リンクをクリックする$/ do |link|
  clicks_link(link)
end

When /再読み込みする/ do
  visit request.request_uri
end

When /^"(.*)"に"(.*)"と入力する$/ do |field, value|
  fills_in(field, :with => value)
end

# opposite order from Engilsh one(original)
When /^"(.*)"から"(.*)"を選択$/ do |field, value|
  selects(value, :from => field)
end

When /^"(.*)"をチェックする$/ do |field|
  checks(field)
end

When /^"(.*)"のチェックを外す$/ do |field|
  unchecks(field)
end

When /^"(.*)"を選択する$/ do |field|
  chooses(field)
end

# opposite order from Engilsh one(original)
When /^"(.*)"としてファイル"(.*)"を添付する$/ do |field, path|
  attaches_file(field, path)
end

Then /^"(.*)"と表示されていること$/ do |text|
  response.body.should =~ /#{Regexp.escape(text)}/m
end

Then /^"(.*)"と表示されていないこと$/ do |text|
  response.body.should_not =~ /#{text}/m
end

Then /^"(.*)"がチェックされていること$/ do |label|
  field_labeled(label).should be_checked
end

