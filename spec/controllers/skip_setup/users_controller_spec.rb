require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe SkipSetup::UsersController do
  before do
    controller.should_receive(:internal_call_only).and_return true
    @client = ClientApplication.create(:name => "SKIP",
                                       :url => "http://skip.example.com",
                                       :callback_url => "http://skip.example.com/oauth_callback")
    @client.grant_as_family!
  end

  describe "POST :create (success)" do
    before do
      post :create, :format => "xml",
        :client_application_id => @client.id,
        :user => {
          :name => "alice",
          :display_name => "アリス",
          :identity_url => "http://op.example.com/u/alice",
        }
    end

    it("response should be success") { response.should be_success }

    describe "assigned user" do
      it{ assigns[:user].should have(2).tokens }
    end

    describe "response" do
      subject{ Hash.from_xml(response.body)["user"] }
      it{ subject["access_token"].should_not be_blank }
      it{ subject["access_secret"].should_not be_blank }
    end
  end
end
