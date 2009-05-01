class SkipSetup::OauthClientsController < ApplicationController
  skip_before_filter :authenticate
  before_filter :internal_call_only

  def create
    @client_application = ClientApplication.new(params[:client_application])
    if @client_application.save
      @client_application.grant_as_family!
      respond_to{|f| f.xml{ render :xml => @client_application } }
    else
      respond_to{|f| f.xml{ render :xml => @client_application.errors.to_xml } }
    end
  end

  private
  def internal_call_only
    :implement_me
  end
end
