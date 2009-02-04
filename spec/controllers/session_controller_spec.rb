require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SessionsController do
  fixtures :users, :accounts
  before do
    controller.session[:user_id] = users(:quentin).id
  end

  describe "GET destroy #SSOでない場合" do
    before do
      FixedOp.sso_openid_provider_url = nil
      get :destroy
    end
    it{ response.should redirect_to login_path }
  end

  describe "GET destroy #SSOの場合" do
    before do
      FixedOp.sso_openid_provider_url = "http://openid.example.com/"
      get :destroy
    end
    it{ response.should redirect_to "http://openid.example.com/logout" }
  end
end
