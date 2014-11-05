require 'rubygems'
require 'bundler/setup'
require 'json'
require 'task'

Bundler.require

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/development.db',
  :encoding => 'utf8'
)

get '/' do
  erb :index
end

get '/todo' do
  # If the todo file exists
  if File.file?("todo.json")
    # Read the todo file
    lis = IO.read("todo.json")
    # Parse it from JSON
    todoList = JSON.parse(lis)
    # Make the array an object
    @list = todoList
  # Otherwise, make a blank task
  else
    blanktask = {"Name" => "Freedom!", "Date" => "Never"}
    blanklist = Array.new
    blanklist.push(blanktask)
    @list = blanklist
  end
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
  # Parse the existing task list into a ruby object, if one exists
  if File.file?("todo.json")
    tasklist = JSON.parse(IO.read("todo.json"))
  else
    tasklist = Array.new
  end
  # Take the POST data and stick it into a new hash
  newtask = {"Name" => "#{params[:task]}", "Date" => "#{params[:date]}"}
  # Add the new hash to the task array 
  tasklist.push(newtask)
  # Open the todo file, truncating to 0
  open("todo.json", "w") { |list|
    #Parse it all back into JSON
    list.puts JSON.pretty_generate(tasklist)
  }
  # Bounces the user back to the original addtask window, rather than leaving a blank page
  redirect to('/addtask')  
end