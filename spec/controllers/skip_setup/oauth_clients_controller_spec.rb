require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe SkipSetup::OauthClientsController do
  before do
    controller.should_receive(:internal_call_only).and_return true
  end

  describe "POST :create (success)" do
    before do
      post :create, :format => "xml", :client_application => {
              :name => "SKIP",
              :url => "http://skip.example.com",
              :callback_url => "http://skip.example.com/oauth_callback"
            }
    end
    it { response.should be_success }

    describe "created client_application" do
      subject { assigns[:client_application] }

      it { should be_granted_by_service_contract }
      it { should_not be_new_record }
      it { subject.key.should_not be_blank }
      it { subject.secret.should_not be_blank }
    end

    describe "/Parse response" do
      subject { Hash.from_xml(response.body)["client_application"] }

      it { subject["id"].should == assigns[:client_application].id }
      it { subject["key"].should_not be_blank }
      it { subject["secret"].should_not be_blank }
    end
  end
end
