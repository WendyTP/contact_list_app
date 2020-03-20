###################################
######  Configuration   ###########
###################################

require "sinatra"
require "sinatra/reloader"
require "sinatra/content_for"
require "tilt/erubis"
require "yaml"
require "bcrypt"


CONTACT_CATEGORIES = [ "Family", "Colleagues", "Friends", "Acquaintances" ]

configure do
  enable :sessions
  set :session_secret, "top secret"
end

before do
  session[:contacts] ||= []
end

###################################
#########  Methods  ###############
###################################

helpers do
  def count_contacts(relation=nil)
    if relation
      session[:contacts].select{ |contact| contact[:relation] == relation}.count
    else
      session[:contacts].count
    end
  end
end

def user_credentials_path
  file_path = File.expand_path("../users.yml", __FILE__)
end

def load_user_credentials
  file_path = user_credentials_path
  YAML.load_file(file_path)
end

def correct_password?(encrypted_password, password)
  BCrypt::Password.new(encrypted_password) == password
end

def invalid_user_credentials(username, password)
  user_credentials = load_user_credentials
  stored_password = user_credentials[username]
  unless user_credentials.keys.include?(username) && correct_password?(stored_password, password)
    "Invalid user credentials."
  end
end

def store_user_credentials(username, password)
  user_credentials = load_user_credentials
  user_credentials[username] = password
  users_yaml = user_credentials.to_yaml
  File.write(user_credentials_path, users_yaml)
end

def invalid_username(username)
  user_credentials = load_user_credentials
  if user_credentials.has_key?(username)
    "Username already exisit."
  elsif username.empty?
    "Username can not be empty."
  end
end

def invalid_password(password, reconfirmed_password)
  if !password.match?((/\A\w{5,20}\z/)) || password != reconfirmed_password
    "Invalid password."
  end
end

def hash_password(password)
  BCrypt::Password.create(password).to_s
end

def signed_in?
  session[:username]
end

def require_to_sign_in
  unless signed_in?
    session[:error]= "You must sign in to access."
    redirect "/"
  end
end

def load_contact(contact_id)
  contact = session[:contacts].find { |contact| contact[:id] == contact_id }
  return contact if contact

  session[:error] = "No such contact exists."
  status 422
  redirect "/contacts"
end

def next_contact_id(contacts)
  max_contact_id = contacts.map{ |contact| contact[:id]}.max || 0
  max_contact_id + 1
end

def invalid_name(firstname, lastname)
  if firstname.empty? || !firstname.match(/\A[\w]+\z/)
    "First Name is not valid."
  elsif lastname.empty? || !lastname.match(/\A[\w]+\z/)
    "Last Name is not valid."
  end
end

def invalid_phone_number(phone)
  unless phone.match(/^(\+|0(\s|\-|\.)?0|0)?((\s|\-|\.)?\d){9,13}$/)
    "Phone number is not valid."
  end
end

def invalid_email(email)
  unless email.match(/^([a-zA-Z]|\d){1}((\.|_|\-)?([a-zA-Z]|\d))+@(([a-zA-Z]|\d){1})((\.|_|\-)?([a-zA-Z]|\d))*\.\w+$/)
    "email is invalid."
  end
end


###################################
########    Routes   ##############
###################################

get "/" do
  erb :home, layout: :layout
end

# view all the contacts
get "/contacts" do
  require_to_sign_in
  @contacts = session[:contacts]

  erb :contacts, layout: :layout
end

# view contacts of individual category
get "/:relation" do
  require_to_sign_in
  @contacts = session[:contacts]
  @relation = params[:relation]

  erb :relation, layout: :layout
end

# render new contact form
get "/contacts/new" do
  require_to_sign_in
  @relations = CONTACT_CATEGORIES
  erb :new_contact, layout: :layout
end

# submit new contact form
post "/contacts" do
  @relations = CONTACT_CATEGORIES
  firstname = params[:firstname].strip
  lastname = params[:lastname].strip
  phone = params[:phone].strip
  email = params[:email].strip
  relation = params[:relation]

  # user input validation
  name_error = invalid_name(firstname, lastname)
  phone_error = invalid_phone_number(phone)
  email_error = invalid_email(email)

  if name_error
    session[:error] = name_error
    status 422
    erb :new_contact, layout: :layout
  elsif phone_error
    session[:error] = phone_error
    status 422
    erb :new_contact, layout: :layout
  elsif email_error
    session[:error] = email_error
    status 422
    erb :new_contact, layout: :layout
  else
    id = next_contact_id(session[:contacts])
    session[:contacts] << {id: id, firstname: firstname, lastname: lastname, phone: phone, email: email, relation: relation}
    session[:success] = "The contact has been added."
    redirect "/"
  end
end

# view single contact
get "/contacts/:id" do
  require_to_sign_in
  @contact_id = params[:id]
  @contact = load_contact(@contact_id.to_i)

  erb :individual_contact, layout: :layout
end

# delete a contact
post "/contacts/:id/delete" do
  require_to_sign_in
  @contact_id = params[:id]
  session[:contacts].delete_if {|contact| contact[:id] == @contact_id.to_i}
  session[:success] = "The contact has been deleted."
  redirect "/"
end

# render edit contact form
get "/contacts/:id/edit" do
  require_to_sign_in
  @contact_id = params[:id]
  contact_info = load_contact(@contact_id.to_i)
  @relations = CONTACT_CATEGORIES

  @firstname = contact_info[:firstname]
  @lastname = contact_info[:lastname]
  @phone = contact_info[:phone]
  @email = contact_info[:email]
  
  erb :edit, layout: :layout
end

# submit eidt contact form
post "/contacts/:id/edit" do
  require_to_sign_in
  contact_id = params[:id].to_i
  contact = load_contact(contact_id)

  firstname = params[:firstname].strip
  lastname = params[:lastname].strip
  phone = params[:phone].strip
  email = params[:email].strip
  relation = params[:relation]
   # user input validation

  new_contact_info = [contact_id, firstname, lastname, phone, email, relation]
  contact.transform_values! {|value| value = new_contact_info.shift}
  session[:success] = "The contact information has been updated."
  redirect "/"
end

# render sign in form
get "/users/signin" do
  erb :signin, layout: :layout
end

# submit sign in form
post "/users/signin" do
  username = params[:username]
  password = params[:password]

  error = invalid_user_credentials(username, password)

  if error
    session[:error] = error
    status 422
    erb :signin, layout: :layout
  else
    session[:username] = username
    session[:success] = "Welcome!"
    redirect "/"
  end
end

# submit sign out form
post "/users/signout" do
  session.delete(:username)
  session[:success] = "You have been signed out."
  redirect "/"
end

# render sign up form
get "/users/signup" do
  erb :signup, layout: :layout
end

# submit sign up form
post "/users/signup" do
  username = params[:username]
  password = params[:password]
  reconfirmed_password = params[:reconfirmed_password]

  username_error = invalid_username(username)
  password_error = invalid_password(password, reconfirmed_password)

  if username_error
    session[:error] = username_error
    status 422
    erb :signup, layout: :layout
  elsif password_error
    session[:error] = password_error
    status 422
    erb :signup, layout: :layout
  else
    hashed_password = hash_password(password)
    store_user_credentials(username, hashed_password)
    session[:username] = username
    session[:success] = "Signed up successfully. Welcome!"
    redirect "/"
  end
end

