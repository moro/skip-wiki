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

  describe ".translate_ax_response w/ axschema.org" do
    before do
      data = {
        "http://axschema.org/contact/email" => ["email@example.com"],
        "http://axschema.org/namePerson"   => ["Human Name"],
        "http://axschema.org/namePerson/friendly" => ["asciiname"],
      }
      @translated = SessionsController.translate_ax_response(data)
    end
    it{ @translated[:name].should == "asciiname" }
    it{ @translated[:display_name].should == "Human Name" }
    it{ @translated[:email].should == "email@example.com" }
  end

  describe ".translate_ax_response w/ both axschema.org and schema.openid.net" do
    before do
      data = {
        "http://schema.openid.net/namePerson"=>["Human Name"],
        "http://schema.openid.net/contact/email"=>["email@example.com"],
        "http://schema.openid.net/namePerson/friendly"=>["asciiname"],
        "http://axschema.org/namePerson"=>[],
        "http://axschema.org/contact/email"=>[],
        "http://axschema.org/namePerson/friendly"=>[],
      }
      @translated = SessionsController.translate_ax_response(data)
    end
    it{ @translated[:name].should == "asciiname" }
    it{ @translated[:display_name].should == "Human Name" }
    it{ @translated[:email].should == "email@example.com" }
  end
end
