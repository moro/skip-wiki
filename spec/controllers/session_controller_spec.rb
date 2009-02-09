require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SessionsController do
  fixtures :users, :accounts
  before do
    controller.session[:user_id] = users(:quentin).id
  end

  describe "POST create" do
    before do
      controller.should_receive(:authenticate_with_open_id).
        and_yield( mock("response", :successful? => true),
                  "http://example.com/alice",
                  {"http://axschema.org/namePerson" => "fullname",
                   "http://axschema.org/namePerson/friendly" => "nick"})
    end

    describe "with FixedOp.sso_enabled? => false" do
      before do
        FixedOp.should_receive(:sso_enabled?).and_return false
        post :create
      end
      it{ session[:user].should be_blank }
      it{ session[:identity_url].should == "http://example.com/alice" }
      it{ response.should render_template( "users/new") }
    end

    describe "with FixedOp.sso_enabled? => true" do
      before do
        FixedOp.should_receive(:sso_enabled?).and_return true
        post :create
      end
      it{ session[:user].should == {:name => "nick", :display_name => "fullname"} }
      it{ session[:identity_url].should == "http://example.com/alice" }
      it{ response.should render_template( "users/new") }
    end

    describe "with FixedOp.sso_enabled? => true/ update User's display name" do
      fixtures :users
      before do
        FixedOp.should_receive(:sso_enabled?).and_return true
        Account.should_receive(:find_by_identity_url).with("http://example.com/alice").
          and_return(account = mock_model(Account))
        account.should_receive(:user).and_return(users(:quentin))

        post :create
      end
      it{ User.find(session[:user_id]).display_name.should == "fullname" }
      it{ flash[:notice].should_not be_blank }
    end
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
        "http://axschema.org/namePerson"   => ["Human Name"],
        "http://axschema.org/namePerson/friendly" => ["asciiname"],
      }
      @translated = SessionsController.translate_ax_response(data)
    end
    it{ @translated[:name].should == "asciiname" }
    it{ @translated[:display_name].should == "Human Name" }
  end

  describe ".translate_ax_response w/ both axschema.org and schema.openid.net" do
    before do
      data = {
        "http://schema.openid.net/namePerson"=>[],
        "http://schema.openid.net/namePerson/friendly"=>[],
        "http://axschema.org/namePerson"=>["Human name"],
        "http://axschema.org/namePerson/friendly"=>["asciiname"],
      }
      @translated = SessionsController.translate_ax_response(data)
    end
    it{ @translated[:name].should == "asciiname" }
    it{ @translated[:display_name].should == "Human name" }
  end
end
