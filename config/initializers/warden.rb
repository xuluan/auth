Rails.application.config.middleware.use Warden::Manager do |manager|
  manager.default_strategies :password
end

Warden::Manager.serialize_into_session do |user|
  user.auth_token
end  

Warden::Manager.serialize_from_session do |token|
  User.find_by_auth_token(token)
end

Warden::Strategies.add(:password) do
  def authenticate!
    
  end

end