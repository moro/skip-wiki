require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::AccountsController do
  fixtures :accounts
  fixtures :users

  before do
    controller.stub!(:current_user).and_return(@user = users(:quentin))
    controller.stub!(:require_admin).and_return(true)
  end


  def mock_account(stubs={})
    @mock_account ||= mock_model(Account, stubs)
  end

  describe "GET /admin/accounts/index" do
    it "Accountが全て取得できていること" do
      Account.should_receive(:find).with(:all).and_return([mock_account])
      get :index
      assigns(:accounts).should == [mock_account]
    end
  end

  describe "GET /admin/accounts/1/edit" do
    it "Accountが1件取得できていること" do
      Account.should_receive(:find).with("7").and_return(mock_account)
      get :edit, :id=>"7"
      assigns(:account).should == mock_account
    end
  end

  describe "PUT /admin/accounts/1" do
    describe "Accountの更新が成功したとき" do
      # TODO 諸橋さんにきく
      it "Accountにリクエストが飛んでいること" do
        Account.should_receive(:find).with("7").and_return(mock_account)
        mock_account.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id=>"7", :account=>{'these'=>'params'}
      end

      it "Accountが正しく更新されていること" do
        Account.stub!(:find).and_return(mock_account(:update_attributes=>true))
        put :update, :id=>"1"
        assigns(:account).should == mock_account
      end
 
      it "アカウント一覧画面にリダイレクトされること" do
        Account.stub!(:find).and_return(mock_account(:update_attributes=>true))        
        put :update, :id=>"1"
        response.should redirect_to(admin_accounts_path)
      end
    end

    describe "Accountの更新が失敗したとき" do
      it "Accountにリクエストが飛んでいること" do
        Account.should_receive(:find).with("7").and_return(mock_account)
        mock_account.should_receive(:update_attributes).with({'these'=>'params'})
        put :update, :id=>"7", :account=>{'these'=>'params'}
      end

      it "Accountが更新されていないこと" do
        Account.stub!(:find).and_return(mock_account(:update_attributes=>false))
        put :update, :id=>"7"
        assigns(:account).should == mock_account
      end

      it "editテンプレートが再読み込みされること" do
        Account.stub!(:find).and_return(mock_account(:update_attributes=>false))
        put :update, :id=>"1"
        response.should redirect_to(edit_admin_account_path("1"))
      end
    end
  end

end
