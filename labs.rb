require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/content_for'

Bundler.require

require './models/Task'

if ENV['DATABASE_URL']
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
else
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => 'db/development.db',
    :encoding => 'utf8'
  )
end

get '/' do
  redirect to('/todo')
end

get '/todo' do
  @list = Task.all
  erb :list
end

get '/addtask' do
  erb :addtask
end

post '/addtask' do
  # Write the date do be "Indefinite" if no date was selected
  date = "#{params[:date]}"
  if (date == "")
    date = "Indefinite"
  end
  Task.create(description: "#{params[:task]}", due: date)
  # Bounces the user back to the original addtask window, rather than leaving a blank page
  redirect to('/addtask')  
end

get '/removetask' do
  @list = Task.all
  erb :removetask
end

post '/removetask' do
  toDestroy = Task.limit(1).order(:due).offset("#{params[:num]}".to_i-1)
  toDestroy.destroy_all
  redirect to('/removetask')
end