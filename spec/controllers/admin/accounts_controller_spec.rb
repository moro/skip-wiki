require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::AccountsController do
  fixtures :accounts

  def mock_account(stubs={})
    @mock_account ||= mock_model(Account, stubs)
  end

  describe "GET /admin/accounts/index" do
    it "Accountsを全て取得すること" do
      Accounts.should_receive(:find).with(:all).and_return([mock_account])
      assigns(:accounts).should == [mock_account]
    end
  end
end
