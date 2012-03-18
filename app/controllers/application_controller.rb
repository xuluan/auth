class ApplicationController < ActionController::Base
  protect_from_forgery
  force_ssl
   
  private
  def current_user
    warden.user
  end

  def warden
    env['warden']
  end

  helper_method :current_user
end
