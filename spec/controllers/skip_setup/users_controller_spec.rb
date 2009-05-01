require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe SkipSetup::UsersController do
  before do
    controller.should_receive(:internal_call_only).and_return true
  end

  describe "POST :create (success)" do
    before do
      @client = mock_model(ClientApplication)
      @client.should_receive(:publish_access_token)
      ClientApplication.should_receive(:find).with("--ID--", anything).and_return @client

      post :create, :format => "xml",
        :client_application_id => "--ID--",
        :user => {
          :name => "alice",
          :display_name => "アリス",
          :identity_url => "http://op.example.com/u/alice",
        }
    end

    it { response.should be_success }
  end
end
