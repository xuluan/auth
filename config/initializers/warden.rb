module Warden::Mixins::Common

  def request
    @request ||= ActionDispatch::Request.new(env)
  end

  def session
    request.cookie_jar.signed
  end 

  alias :raw_session :session  

  def reset_session!
    request.cookie_jar.each do |k,v|
      request.cookie_jar.delete(k)
    end
  end

end

module Warden
  class SessionSerializer
    def store(user, scope)
      return unless user
      if user.respond_to?(:warden_remember_me) && user.warden_remember_me
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
      if params[:remember_me]
        user.define_singleton_method(:warden_remember_me) {true}
      end
      success! user
    else
      fail "Invalid email or password"
    end

  end

end