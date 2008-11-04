class UsersController < ApplicationController
  def show
    unless @user = (id=params[:id]) =~ /\d+/ ?  User.find(id) : User.find_by_login(id)
      raise ActiveRecord::RecordNotFound
    end
  end
end
