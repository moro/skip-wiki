class SkipSetup::UsersController < SkipSetup::ApplicationController
  def create
    client = ClientApplication.families.find(params[:client_application_id])
    @user, token = create_user_and_token(client, params[:user])
    respond_to do |f|
      f.xml{ render :xml => api_response(@user, token).to_xml(:root => "user") }
    end
  rescue ActiveRecord::RecordNotFound => why
    respond_to do |f|
      f.xml{ render :xml => @user.errors.to_xml }
    end
  end

  private

  def create_user_and_token(client, user_param)
    user = User.new(user_param){|u| u.identity_url = user_param[:identity_url] }
    ActiveRecord::Base.transaction do
      user.save!
      return [user, client.publish_access_token(user)]
    end
  end

  def api_response(user, token)
    return nil unless token
    returning( user.attributes.slice(:identity_url) ) do |res|
      res["access_token"] = token.token
      res["access_secret"] = token.secret
    end
  end
end
