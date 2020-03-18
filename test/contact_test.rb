ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"

require_relative "../contact"

class ContactTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    # something
  end

  def teardown
    #something
  end

  def test_index
    get "/"
    assert_equal(200, last_response.status)
    #assert_includes(last_response.body, "Add contact")
    assert_includes(last_response.body, "Family")
  end

  def test_view_contacts
    get "/contacts"
    assert_equal(200, last_response.status)
    assert_includes(last_response.body, %q(<a href=/contacts/1>Amy Smith))
  end


  def test_view_individual_category_contacts
    get "/Family"
    assert_equal(200, last_response.status)
    assert_includes(last_response.body,  %q(<a href=/contacts/1>Amy Smith))
    
  end


  def test_view_single_contact
    get "/contacts/:id"

    #assert_equal(200, last_response.status)
    #assert_includes(last_response.body, "First Name:")
    #assert_includes(last_response.body, "Amy")
  end

  

end