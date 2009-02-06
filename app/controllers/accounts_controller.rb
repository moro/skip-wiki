class AccountsController < ApplicationController
  skip_before_filter :login_required
  def new
    @account = Account.new
  end

end
