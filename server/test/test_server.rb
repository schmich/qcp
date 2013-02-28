require 'server'
require 'test/unit'
require 'rack/test'

set :environment, :test

class QcpServerTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
  end

  def teardown
  end

  def test_no_index
    get '/'
    assert_equal 404, last_response.status
  end
end
