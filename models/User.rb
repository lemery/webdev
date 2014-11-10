class User < ActiveRecord::Base
  serialize :password
end