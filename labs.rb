require 'rubygems'
require 'bundler/setup'
require 'json'

Bundler.require

get '/' do
  erb :index
end

get '/todo' do
  # Read the todo file
  lis = IO.read("todo")
  # Parse it from JSON
  todoList = JSON.parse(lis)
  # Make the array an object
  @list = todoList
  erb :list
end

get '/addtask' do
  erb :addtask
end

def sort_tasks(tasklist)
  temp = Array.new
  
end

post '/addtask' do
  # Write the date do be "Indefinite" if no date was selected
  date = "#{params[:date]}"
  if (date == "")
    date = "Indefinite"
  end
  # Parse the existing task list into a ruby object
  tasklist = JSON.parse(IO.read("todo"))
  # Take the POST data and stick it into a new hash
  newtask = {"Name" => "#{params[:task]}", "Date" => "#{params[:date]}"}
  # Add the new hash to the task array 
  tasklist.push(newtask)
  # Open the todo file, truncating to 0
  open("todo", "w") { |list|
    #Parse it all back into JSON
    list.puts JSON.pretty_generate(tasklist)
  }
  # Bounces the user back to the original addtask window, rather than leaving a blank page
  redirect to('/addtask')  
end