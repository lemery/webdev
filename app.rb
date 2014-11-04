# app.rb
# this is a simple Sinatra example app

# use bundler
require 'rubygems'
require 'bundler/setup'
# load all of the gems in the gemfile
Bundler.require

# define a route for the root of the site
get '/' do
  # render the views/index.erb template
	erb :index
end

# define another route with some content that's then shown by the view
get '/99bottles' do
  # Ruby is fun because you can mix functional programming with imperative programming. 
  # Here we specify a Range from 1 to 99, convert it into an Array, reverse the Array order, 
  # then map a block to the Array that converts each Integer into a String using ruby string 
  # interpolation (the #{} stuff)
  @lyrics = (1..99).to_a.reverse.map {|i| "#{i} bottles of beer on the wall, #{i} bottles of beer. Take one down, pass it around, #{i-1} bottles of beer on the wall."}
  # renter the views/bottles.erb template
  erb :bottles
end