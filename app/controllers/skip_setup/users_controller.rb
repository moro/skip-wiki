class SkipSetup::UsersController < SkipSetup::ApplicationController
  def create
    @user = User.new(params[:user]) do |user|
      user.identity_url = params[:user][:identity_url]
    end
    ActiveRecord::Base.transaction do
      @user.save!
      @client = ClientApplication.find(params[:client_application_id], :FIXME)
      @client.publish_access_token(@user)
    end
    respond_to do |f|
      f.xml{ render :xml => @user.to_xml }
    end
  rescue ActiveRecord::RecordNotFound => why
    render(:text => "")
  end
end
