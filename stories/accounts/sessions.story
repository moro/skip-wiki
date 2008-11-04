Users want to know that nobody can masquerade as them.  We want to extend trust
only to visitors who present the appropriate credentials.  Everyone wants this
identity verification to be as secure and convenient as possible.

Story: Logging in
  As an anonymous account with an account
  I want to log in to my account
  So that I can be myself

  #
  # Log in: get form
  #
  Scenario: Anonymous account can get a login form.
    Given an anonymous account
    When  she goes to /login
    Then  she should be at the new logins page
     And  the page should look AWESOME
     And  she should see a <form> containing a textfield: Login, password: Password, and submit: 'Log in'
  
  #
  # Log in successfully, but don't remember me
  #
  Scenario: Anonymous account can log in
    Given an anonymous account
     And  an activated account named 'reggie'
    When  she creates a singular logins with login: 'reggie', password: 'monkey', remember me: ''
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see a notice message 'Logged in successfully'
     And  reggie should be logged in
     And  she should not have an auth_token cookie
   
  Scenario: Logged-in account who logs in should be the new one
    Given an activated account named 'reggie'
     And  an activated account logged in as 'oona'
    When  she creates a singular logins with login: 'reggie', password: 'monkey', remember me: ''
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see a notice message 'Logged in successfully'
     And  reggie should be logged in
     And  she should not have an auth_token cookie
  
  #
  # Log in successfully, remember me
  #
  Scenario: Anonymous account can log in and be remembered
    Given an anonymous account
     And  an activated account named 'reggie'
    When  she creates a singular logins with login: 'reggie', password: 'monkey', remember me: '1'
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see a notice message 'Logged in successfully'
     And  reggie should be logged in
     And  she should have an auth_token cookie
	      # assumes fixtures were run sometime
     And  her session store should have account_id: 4
   
  #
  # Log in unsuccessfully
  #
  
  Scenario: Logged-in account who fails logs in should be logged out
    Given an activated account named 'oona'
    When  she creates a singular logins with login: 'oona', password: '1234oona', remember me: '1'
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see a notice message 'Logged in successfully'
     And  oona should be logged in
     And  she should have an auth_token cookie
    When  she creates a singular logins with login: 'reggie', password: 'i_haxxor_joo'
    Then  she should be at the new logins page
    Then  she should see an error message 'Couldn't log you in as 'reggie''
     And  she should not be logged in
     And  she should not have an auth_token cookie
     And  her session store should not have account_id
  
  Scenario: Log-in with bogus info should fail until it doesn't
    Given an activated account named 'reggie'
    When  she creates a singular logins with login: 'reggie', password: 'i_haxxor_joo'
    Then  she should be at the new logins page
    Then  she should see an error message 'Couldn't log you in as 'reggie''
     And  she should not be logged in
     And  she should not have an auth_token cookie
     And  her session store should not have account_id
    When  she creates a singular logins with login: 'reggie', password: ''
    Then  she should be at the new logins page
    Then  she should see an error message 'Couldn't log you in as 'reggie''
     And  she should not be logged in
     And  she should not have an auth_token cookie
     And  her session store should not have account_id
    When  she creates a singular logins with login: '', password: 'monkey'
    Then  she should be at the new logins page
    Then  she should see an error message 'Couldn't log you in as '''
     And  she should not be logged in
     And  she should not have an auth_token cookie
     And  her session store should not have account_id
    When  she creates a singular logins with login: 'leonard_shelby', password: 'monkey'
    Then  she should be at the new logins page
    Then  she should see an error message 'Couldn't log you in as 'leonard_shelby''
     And  she should not be logged in
     And  she should not have an auth_token cookie
     And  her session store should not have account_id
    When  she creates a singular logins with login: 'reggie', password: 'monkey', remember me: '1'
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see a notice message 'Logged in successfully'
     And  reggie should be logged in
     And  she should have an auth_token cookie
	      # assumes fixtures were run sometime
     And  her session store should have account_id: 4


  #
  # Log out successfully (should always succeed)
  #
  Scenario: Anonymous (logged out) account can log out.
    Given an anonymous account
    When  she goes to /logout
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see a notice message 'You have been logged out'
     And  she should not be logged in
     And  she should not have an auth_token cookie
     And  her session store should not have account_id

  Scenario: Logged in account can log out.
    Given an activated account logged in as 'reggie'
    When  she goes to /logout
    Then  she should be redirected to the home page
    When  she follows that redirect!
    Then  she should see a notice message 'You have been logged out'
     And  she should not be logged in
     And  she should not have an auth_token cookie
     And  her session store should not have account_id
