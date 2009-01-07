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
    it "Userを全て取得していること" do
      User.should_receive(:find).with(:all).and_return([mock_user])
      get :index
      assigns(:users).should == [mock_user]
    end
  end

  describe "GET /admin/users/1/edit" do
    it "Userが１件取得できていること" do
      User.should_receive(:find).with("7").and_return(mock_user)
      get :edit, :id => "7"
      assigns(:user).should == mock_user
    end 
  end

  # TODO
  describe "PUT /admin/users/1" do
    describe "User" do
      it "User" do
        User.should_receive(:find).with("7").and_return(mock_user)
        mock_user.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id=>"7", :user=>{'these'=>'params'}
      end

      it "User" do
        User.stub!(:find).and_return(mock_user(:update_attributes=>true))
        put :update, :id=>"1"
        assigns(:user).should == mock_user
      end

      it "User" do
        User.stub!(:find).and_return(mock_user(:update_attributes=>true))
        put :update, :id=>"1"
        response.should redirect_to(admin_root_path)
      end
    end

    describe "User" do
      it "User" do
        User.should_receive(:find).with("7").and_return(mock_user)
        mock_user.should_receive(:update_attributes).with({'these'=>'params'})
        put :update, :id=>"7", :user=>{'these'=>'params'}
      end
    end
  end

end
