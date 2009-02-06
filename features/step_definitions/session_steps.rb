Given /there are (\d+) sessions/ do |n|
  Session.transaction do
    Session.destroy_all
    n.to_i.times do |n|
      Session.create! :name => "Session #{n}"
    end
  end
end

Given(/ユーザ"(\w+)"を登録する/) do |name|
  @user = User.new(:name => name, :display_name => name.humanize)
end

Given(/ユーザのIdentity URLを"(.+)"として登録する/) do |url|
  @user.account = Account.new{|a| a.identity_url = url }
  @user.save!
end

def create_user_as(name)
  url = "http://localhost:3200/user/#{name}"
  returning( User.new(:name => name, :display_name => name.humanize) ) do |u|
    u.account = Account.new{|a| a.identity_url = url }
    u.save!
  end
end

Given(/ユーザ"(\w+)"を登録し、ログインする/) do |name|
  @user = create_user_as(name)
  authenticate_with_fake_open_id_server(@user.account.identity_url)
end

Given(/ユーザ"(\w+)"を管理者として登録し、ログインする/) do |name|
  @user = create_user_as(name)
  @user.update_attribute(:admin, true)

  authenticate_with_fake_open_id_server(@user.account.identity_url)
end

Then /there should be (\d+) sessions left/ do |n|
  Session.count.should == n.to_i
  response.should have_tag("table tr", n.to_i + 1) # There is a header row too
end

