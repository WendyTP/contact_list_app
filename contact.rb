require "sinatra"
require "sinatra/reloader"
require "sinatra/content_for"
require "tilt/erubis"


CONTACT_CATEGORIES = [ "Family", "Colleagues", "Friends", "Acquaintances" ]

configure do
  enable :sessions
  set :session_secret, "top secret"
end

before do
  session[:contacts] ||= []
end

helpers do
  # something
end


get "/" do
  erb :home, layout: :layout
end

get "/all_contacts" do
  # something
end

get "/:relation" do
  # something
end

