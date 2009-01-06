require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::ApplicationController, "#require_admin" do

  describe "管理者ではない場合" do
    before do
      controller.stub!(:login_required).and_return(true)
      @user = mock_model(User)
      @user.should_receive(:admin?).and_return(false)
      controller.should_receive(:current_user).and_return(@user)
      controller.stub!(:root_url).and_return('http://localhost:3000/')
      controller.stub!(:redirect_to).with('http://localhost:3000/')
    end
   
    it "map.rootにリダイレクトされること" do
      controller.should_receive(:redirect_to).and_return('http://localhost:3000/')
      controller.require_admin
    end

    it "falseが返されること" do
      controller.require_admin.should be_false
    end
  end

end

