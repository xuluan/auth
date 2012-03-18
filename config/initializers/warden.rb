module Warden::Mixins::Common

  WARDEN_EXT_SESSION_KEY = 'warden.ext'.freeze

  def request
    @request ||= ActionDispatch::Request.new(env)
  end

  def session
    #restore_cookies if(request.cookie_jar[WARDEN_EXT_SESSION_KEY].class == String)
    #request.cookie_jar[WARDEN_EXT_SESSION_KEY] ||= {:value=>{}}
    request.cookie_jar.signed

  end # session
  alias :raw_session :session  

  def reset_session!
    request.cookie_jar.each do |k,v|
      request.cookie_jar.delete(k)
    end
  end

  private
  #def restore_cookies
  #  string = request.cookie_jar[WARDEN_EXT_SESSION_KEY]
  #  hash = eval(string)
  #  request.cookie_jar[WARDEN_EXT_SESSION_KEY] = {:value=>hash}
  #end
end

module Warden
  class SessionSerializer
    def store(user, scope)
      return unless user
      if user.respond_to?(:remember_me) && user.remember_me
        session.permanent[key_for(scope)] = serialize(user)
      else
        session[key_for(scope)] = serialize(user)
      end
    end    
  end
end

Rails.application.config.middleware.use Warden::Manager do |manager|
  manager.default_strategies :password
end

Warden::Manager.serialize_into_session do |user|
  user.id
end  

Warden::Manager.serialize_from_session do |id|
  User.find(id)
end

Warden::Strategies.add(:password) do
  def authenticate!
    user = User.find_by_email(params['email'])
    if user && user.authenticate(params['password'])
      user.remember_me = params[:remember_me] 
      success! user
    else
      fail "Invalid email or password"
    end

  end

end