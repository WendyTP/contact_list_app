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



end