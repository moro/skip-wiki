class AccountsController < ApplicationController
  skip_before_filter :authenticate
  def new
    @account = Account.new
  end

end
