Given /there are (\d+) sessions/ do |n|
  Session.transaction do
    Session.destroy_all
    n.to_i.times do |n|
      Session.create! :name => "Session #{n}"
    end
  end
end

Given(/ユーザ"(\w+)"を登録する/) do |name|
  @account = Account.new(:login => name, :email => name+"@example.com")
end

Given(/ユーザのIdentity URLを"(.+)"として登録する/) do |url|
  @account.identity_url = url
  @account.save!
end

Given(/ユーザ"(\w+)"を登録し、ログインする/) do |name|
  @account = Account.new(:login => name, :email => name+"@example.com")
  @account.identity_url = "http://localhost:3333/user/#{name}"
  @account.save!

  authenticate_with_fake_open_id_server(@account.identity_url)
end

Then /there should be (\d+) sessions left/ do |n|
  Session.count.should == n.to_i
  response.should have_tag("table tr", n.to_i + 1) # There is a header row too
end

