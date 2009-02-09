#!/usr/bin/env ruby
# vim:set fileencoding=utf-8 filetype=ruby
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do
  describe "post :create" do
    before do
      params = {"user"=>{"name"=>"ascii", "display_name"=>"Human Name"}}
      session[:identity_url] = "http://openid.example.com/ascii"

      post :create, params
    end

    it{ response.should be_redirect }
    it{ session[:identity_url].should be_blank }

    it{ assigns(:user).account.should_not be_new_record }
    it{ assigns(:user).account.identity_url.should == "http://openid.example.com/ascii" }

    it{ assigns(:user).should_not be_new_record }
    it{ assigns(:user).name.should == "ascii" }
    it{ assigns(:user).display_name.should == "Human Name" }
  end

  describe "post :create when FixedOp.sso_enabled?" do
    before do
      FixedOp.should_receive(:sso_enabled?).and_return true
      session[:user] = {"name"=>"ascii", "display_name"=>"Human Name"}
      session[:identity_url] = "http://openid.example.com/ascii"

      post :create, :user => {:display_name => "this should be ignored", :name => "malicious"}
    end

    it{ response.should be_redirect }
    it{ session[:identity_url].should be_blank }
    it{ session[:user].should be_blank }

    it{ assigns(:user).account.should_not be_new_record }
    it{ assigns(:user).account.identity_url.should == "http://openid.example.com/ascii" }

    it{ assigns(:user).should_not be_new_record }
    it{ assigns(:user).name.should == "ascii" }
    it{ assigns(:user).display_name.should == "Human Name" }
  end

  describe "post :create failed" do
    before do
      params = {"user"=>{"name"=>"", "display_name"=>"Human Name"}}
      session[:identity_url] = "http://openid.example.com/ascii"

      post :create, params
    end

    it{ response.should render_template("new") }

    it{ assigns(:user).account.should be_new_record }
    it{ assigns(:user).account.identity_url.should == "http://openid.example.com/ascii" }

    it{ assigns(:user).should be_new_record }
    it{ assigns(:user).name.should == "" }
    it{ assigns(:user).display_name.should == "Human Name" }
  end
end
