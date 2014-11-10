require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/content_for'
require 'bcrypt'

Bundler.require

require './models/Task'
require './models/User'

enable :sessions

if ENV['DATABASE_URL']
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
else
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => 'db/development.db',
    :encoding => 'utf8'
  )
end

def username
  return session[:username]
end

def logged_in?
  if (session[:logged_in])
    return true
  else
    return false
  end
end

def authorized? (restrictedTo)
  if (((username == restrictedTo) || session[:admin]) && logged_in?)
    return true
  else
    return false
  end
end

def restricted
  redirect to('/auth/restricted')
end

def userid (user)
  return User.find_by(username: user).id
end

def user_tasks (user)
  return Task.where(user_id: userid(user))
end

get '/auth/signup' do
  erb :signup
end

post '/auth/signup' do
  if "#{params[:user_password]}" != "#{params[:user_password_confirmation]}"
    flash[:password_match_fail] = "Passwords did not match"
  else
    if User.exists?(:username => "#{params[:user_name]}")
      flash[:username_taken] = "Username already taken"
    else
      user = User.new
      user.username = "#{params[:user_name]}"
      user.password = BCrypt::Password.create("#{params[:user_password]}") 
      user.isAdmin = user.username == "Admin"
      user.save
      session[:logged_in] = true
      session[:username] = user.username
      session[:admin] = user.isAdmin
      redirect to('/')
    end
  end
  redirect to('/auth/signup')
end

get '/' do
  erb :index
end

get '/auth/login' do
  erb :login
end

post '/auth/login' do
  login_attempt = User.find_by_username!("#{params[:user_name]}")
  if login_attempt.password == "#{params[:password_attempt]}"
    session[:logged_in] = true
    session[:username] = login_attempt.username
    session[:admin] = User.find_by_username(session[:username]).isAdmin
    redirect to("/")
  else
    flash[:incorrect] = "Username or password invalid"
    redirect to('/auth/login')
  end
end

get '/auth/logout' do
    session[:username] = nil
    session[:admin] = false
    session[:logged_in] = false
    redirect to('/')
end

get '/auth/restricted' do
  erb :restricted
end

get '/todo' do
  if logged_in?
    redirect to("#{session[:username]}/todo")
  else
    restricted
  end
end

get '/:user/todo' do
  if (authorized? (params[:user]))
    @list = user_tasks(params[:user])
    erb :list
  else
    restricted
  end
end

get '/addtask' do
  if (logged_in?)
    redirect to("#{session[:username]}/addtask")
  else
    restricted
  end
end

get '/:user/addtask' do
  if (authorized? (params[:user]))
    @username = params[:user]
    erb :addtask
  else
    restricted
  end
end

post '/:user/addtask' do
  if (authorized? (params[:user]))
    # Write the date do be "Indefinite" if no date was selected
    date = "#{params[:date]}"
    if (date == "")
      date = "Indefinite"
    end
    Task.create(user_id: userid(params[:user]), description: "#{params[:task]}", due: date)
  else
    return status(403)
  end
  @list = user_tasks(params[:user])
  erb :addtask
end

get '/removetask' do
  if (logged_in?)
    redirect to("#{session[:username]}/removetask")
  else
    restricted
  end
end

get '/:user/removetask' do
  if (authorized? (params[:user]))
    @list = user_tasks(params[:user])
    erb :removetask
  else
    restricted
  end
end

post '/:user/removetask' do
  if (authorized? (params[:user]))
    user_tasks(params[:user]).limit(1).offset("#{params[:num]}".to_i-1).destroy_all
    @list = user_tasks(params[:user])
    erb :removetask
  else
    return status(403)
  end
end