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

def load_contact(contact_id)
  contact = session[:contacts].find { |contact| contact[:id] == contact_id }
  return contact if contact

  session[:error] = "No such contact exisits."

  redirect "/contacts"
end


get "/" do
  erb :home, layout: :layout
end

# view all the contacts
get "/contacts" do

  session[:contacts] << {id: 1, firstname: "Amy", lastname: "Smith", phone: "123456789", email: "example@", relation: "Family"}
  session[:contacts] << {id: 2, firstname: "John", lastname: "Smith", phone: "123456789", email: "example@", relation: "Friends"}
  session[:contacts] << {id: 3, firstname: "Ben", lastname: "Smith", phone: "123456789", email: "example@", relation: "Family"}
 
  @contacts = session[:contacts]

  erb :contacts, layout: :layout
end

# view contacts of individual category
get "/:relation" do
  @contacts = session[:contacts]
  @relation = params[:relation]

  erb :relation, layout: :layout
end

# view single contact
get "/contacts/:id" do
  contact_id = params[:id].to_i
  @contact = load_contact(contact_id)  # {id:1, firstname: "A", lastname: "S", phone: "122", email: "wwrr", relation: "Family"}

  erb :individual_contact, layout: :layout
end

