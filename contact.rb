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

def load_contact(contact_id)
  contact = session[:contacts].find { |contact| contact[:id] == contact_id }
  return contact if contact

  session[:error] = "No such contact exisits."

  redirect "/contacts"
end

def next_contact_id(contacts)
  max_contact_id = contacts.map{ |contact| contact[:id]}.max || 0
  max_contact_id + 1
end


get "/" do
  erb :home, layout: :layout
end

# view all the contacts
get "/contacts" do
  @contacts = session[:contacts]

  erb :contacts, layout: :layout
end

# view contacts of individual category
get "/:relation" do
  @contacts = session[:contacts]
  @relation = params[:relation]

  erb :relation, layout: :layout
end

# render new contact form
get "/contacts/new" do
  @relations = CONTACT_CATEGORIES
  erb :new_contact, layout: :layout
end

# submit new contact form
post "/contacts" do
  firstname = params[:firstname].strip
  lastname = params[:lastname].strip
  phone = params[:phone].strip
  email = params[:email].strip
  relation = params[:relation]
  # user input validation 
  # no same first name + last name contact
  id = next_contact_id(session[:contacts])
  session[:contacts] << {id: id, firstname: firstname, lastname: lastname, phone: phone, email: email, relation: relation}
  session[:success] = "The contact has been added."
  redirect "/"
end

# view single contact
get "/contacts/:id" do
  contact_id = params[:id].to_i
  @contact = load_contact(contact_id)  # {id:1, firstname: "A", lastname: "S", phone: "122", email: "wwrr", relation: "Family"}

  erb :individual_contact, layout: :layout
end



