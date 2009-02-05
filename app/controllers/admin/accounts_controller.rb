class Admin::AccountsController < Admin::ApplicationController
  layout "admin_users"

  def index
    @accounts = Account.fulltext(params[:keyword])
  end

  def edit
    @account = Account.find(params[:id])
  end

  def update
    @account = Account.find(params[:id])
    if @account.update_attributes(params[:account])
      flash[:notice] = _("Account update successfully.")
      redirect_to admin_accounts_path
    else
      flash[:error] = _("validation error")
      redirect_to :action => 'edit'
    end
  end
end
