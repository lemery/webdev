require 'rubygems'
require 'bundler/setup'

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
  erb :index
end

get '/todo' do
  @list = Task.all
  # Display through list.erb, replacing layout.erb entirely
  erb :list, :layout => :list
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
  Task.create(description: "#{params[:task]}", due: "#{params[:date]}")
  # Bounces the user back to the original addtask window, rather than leaving a blank page
  redirect to('/addtask')  
end