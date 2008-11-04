require File.dirname(__FILE__) + '/../helper'

RE_Account      = %r{(?:(?:the )? *(\w+) *)}
RE_Account_TYPE = %r{(?: *(\w+)? *)}
steps_for(:account) do

  #
  # Setting
  #
  
  Given "an anonymous account" do 
    log_out!
  end

  Given "$an $account_type account with $attributes" do |_, account_type, attributes|
    create_account! account_type, attributes.to_hash_from_story
  end
  
  Given "$an $account_type account named '$login'" do |_, account_type, login|
    create_account! account_type, named_account(login)
  end
  
  Given "$an $account_type account logged in as '$login'" do |_, account_type, login|
    create_account! account_type, named_account(login)
    log_in_account!
  end
  
  Given "$actor is logged in" do |_, login|
    log_in_account! @account_params || named_account(login)
  end
  
  Given "there is no $account_type account named '$login'" do |_, login|
    @account = Account.find_by_login(login)
    @account.destroy! if @account
    @account.should be_nil
  end
  
  #
  # Actions
  #
  When "$actor logs out" do 
    log_out
  end

  When "$actor registers an account as the preloaded '$login'" do |_, login|
    account = named_account(login)
    account['password_confirmation'] = account['password']
    create_account account
  end

  When "$actor registers an account with $attributes" do |_, attributes|
    create_account attributes.to_hash_from_story
  end
  

  When "$actor logs in with $attributes" do |_, attributes|
    log_in_account attributes.to_hash_from_story
  end
  
  #
  # Result
  #
  Then "$actor should be invited to sign in" do |_|
    response.should render_template('/logins/new')
  end
  
  Then "$actor should not be logged in" do |_|
    controller.logged_in?.should_not be_true
  end
    
  Then "$login should be logged in" do |login|
    controller.logged_in?.should be_true
    controller.current_account.should === @account
    controller.current_account.login.should == login
  end
    
end

def named_account login
  account_params = {
    'admin'   => {'id' => 1, 'login' => 'addie', 'password' => '1234addie', 'email' => 'admin@example.com',       },
    'oona'    => {          'login' => 'oona',   'password' => '1234oona',  'email' => 'unactivated@example.com'},
    'reggie'  => {          'login' => 'reggie', 'password' => 'monkey',    'email' => 'registered@example.com' },
    }
  account_params[login.downcase]
end

#
# Account account actions.
#
# The ! methods are 'just get the job done'.  It's true, they do some testing of
# their own -- thus un-DRY'ing tests that do and should live in the account account
# stories -- but the repetition is ultimately important so that a faulty test setup
# fails early.  
#

def log_out 
  get '/logins/destroy'
end

def log_out!
  log_out
  response.should redirect_to('/')
  follow_redirect!
end

def create_account(account_params={})
  @account_params       ||= account_params
  post "/accounts", :account => account_params
  @account = Account.find_by_login(account_params['login'])
end

def create_account!(account_type, account_params)
  account_params['password_confirmation'] ||= account_params['password'] ||= account_params['password']
  create_account account_params
  response.should redirect_to('/')
  follow_redirect!

end



def log_in_account account_params=nil
  @account_params ||= account_params
  account_params  ||= @account_params
  post "/login", account_params
  @account = Account.find_by_login(account_params['login'])
  controller.current_account
end

def log_in_account! *args
  log_in_account *args
  response.should redirect_to('/')
  follow_redirect!
  response.should have_flash("notice", /Logged in successfully/)
end
