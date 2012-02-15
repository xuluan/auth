class User < ActiveRecord::Base
  attr_accessible :email, :password, :pasword_confirmation
  has_secure_password
  validates_presence_of :password, :on => :create
end
