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


end