require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::UsersController do
  fixtures :users
  before do
    controller.stub!(:current_user).and_return(@user = users(:quentin))
    controller.stub!(:require_admin).and_return(true)
  end

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs)
  end

  describe "GET /admin/users/index" do
    it "Userが全件取得できていること" do
      User.should_receive(:find).with(:all).and_return([mock_user])
      get :index
      assigns(:users).should == [mock_user]
    end
  end

  describe "GET /admin/users/1/edit" do
    it "Userが1件取得できていること" do
      User.should_receive(:find).with("7").and_return(mock_user)
      get :edit, :id => "7"
      assigns(:user).should == mock_user
    end 
  end

  describe "PUT /admin/users/1" do
    describe "Userの更新に成功する場合" do
      it "User更新のリクエストが飛んでいること" do
        User.should_receive(:find).with("7").and_return(mock_user)
        mock_user.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id=>"7", :user=>{'these'=>'params'}
      end

      it "Userの更新ができていること" do
        User.stub!(:find).and_return(mock_user(:update_attributes=>true))
        put :update, :id=>"1"
        assigns(:user).should == mock_user
      end

      it "更新後、ユーザ一覧にリダイレクトされること" do
        User.stub!(:find).and_return(mock_user(:update_attributes=>true))
        put :update, :id=>"1"
        response.should redirect_to(admin_root_path)
      end
    end

    describe "Userの更新に失敗した場合" do
      it "updateにUser更新のリクエストが飛んでいること" do
        User.should_receive(:find).with("7").and_return(mock_user)
        mock_user.should_receive(:update_attributes).with({'these'=>'params'})
        put :update, :id=>"7", :user=>{'these'=>'params'}
      end

      it "更新処理が失敗していること" do
        User.stub!(:find).and_return(mock_user(:update_attributes => false))
        put :update, :id => "7"
        assigns(:user).should equal(mock_user)
      end

      it "編集画面にリダイレクトされること" do
        User.stub!(:find).and_return(mock_user(:update_attributes => false))
        put :update, :id => "7"
        response.should redirect_to(edit_admin_user_path("7"))
      end
    end
  end

end
