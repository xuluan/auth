class SessionsController < ApplicationController
  def new
  end

  def create
    user = warden.authenticate
    if user
      redirect_to root_url, :notice => "Logged in!"
    else
      flash.now.alert = env['warden'].message
      render "new"
    end    
  end

  def destroy
    warden.logout
    #cookies.delete(:auth_token)
    redirect_to root_url, :notice => "Logged out!"
  end
end
