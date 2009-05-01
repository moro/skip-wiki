require File.dirname(__FILE__) + '/../spec_helper'
module OAuthSpecHelpers
  
  def create_consumer
    @consumer = OAuth::Consumer.new(@application.key,@application.secret,
      {
        :site => @application.oauth_server.base_url
      })
  end
  
  def create_test_request
    
  end
  
  def create_oauth_request
    @token = AccessToken.create :client_application => @application, :user => users(:quentin)
    @request = @consumer.create_signed_request(:get, "/hello", @token)
  end
  
  def create_request_token_request
    @request = @consumer.create_signed_request(:get, @application.oauth_server.request_token_path, @token)
  end
  
  def create_access_token_request
    @token = RequestToken.create :client_application => @application
    @request = @consumer.create_signed_request(:get, @application.oauth_server.request_token_path, @token)
  end
  
end

describe ClientApplication do #, :shared => true do
  include OAuthSpecHelpers
  fixtures :users, :client_applications, :oauth_tokens
  describe "not SKIP family" do
    before(:each) do
      @application = ClientApplication.create :name => "Agree2", :url => "http://agree2.com", :user => users(:quentin), :family => true
      create_consumer
    end

    it "should be valid" do
      @application.should be_valid
    end

    it "should not skip family" do
      @application.should_not be_granted_by_service_contract
    end
    
    it "should have key and secret" do
      @application.key.should_not be_nil
      @application.secret.should_not be_nil
    end

    it "should have credentials" do
      @application.credentials.should_not be_nil
      @application.credentials.key.should == @application.key
      @application.credentials.secret.should == @application.secret
    end
  end

  describe "SKIP family" do
    before(:each) do
      @application = ClientApplication.create :name => "Agree2", :url => "http://agree2.com"
      @application.grant_as_family!
      create_consumer
    end

    it "should be valid" do
      @application.should be_valid
    end

    it "should not skip family" do
      @application.should be_granted_by_service_contract
    end

    describe ".publish_access_token" do
      Spec::Matchers.define :have_authorized_access_token_for do |app|
        description{ "have authorized AccessToken for #{app.to_s}" }

        match do |user|
          t, = app.tokens.find_all_by_type_and_user_id("AccessToken", user)
          t.authorized?
        end
      end

      Spec::Matchers.define :have_invalidated_request_token_for do |app|
        description{ "have invalidated RequestToken for #{app.to_s}" }

        match do |user|
          t, = app.tokens.find_all_by_type_and_user_id("RequestToken", user)
          t.invalidated?
        end
      end

      subject { User.create(:name => "alice", :display_name => "alice"){|u| u.identity_url = "---" } }

      before do
        @application.publish_access_token(subject)
      end

      it{ should have(2).tokens }
      it{ should have_authorized_access_token_for(@application) }
      it{ should have_invalidated_request_token_for(@application) }
    end
  end
end

